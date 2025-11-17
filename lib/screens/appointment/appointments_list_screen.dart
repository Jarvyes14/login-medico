import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import 'appointment_detail_screen.dart';
import 'edit_appointment_screen.dart';
import 'book_appointment_screen.dart';

class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Mis Citas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No hay usuario autenticado'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Mis Citas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Determinar si es doctor o paciente
    final isDoctor = _currentUser?.isDoctor ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isDoctor ? 'Citas de Pacientes' : 'Mis Citas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: isDoctor
            ? _firestoreService.getDoctorAppointments(user.uid)
            : _firestoreService.getUserAppointments(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar las citas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isDoctor
                        ? 'No tienes citas agendadas'
                        : 'No tienes citas agendadas',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isDoctor
                        ? 'Los pacientes podrán agendar citas contigo'
                        : 'Agenda tu primera cita médica',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (!isDoctor) ...[
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookAppointmentScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Agendar Cita'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // Separar citas por estado
          final upcomingAppointments = appointments
              .where((apt) =>
                  apt.estado != 'cancelada' &&
                  apt.fechaHora.isAfter(DateTime.now()))
              .toList();
          final pastAppointments = appointments
              .where((apt) =>
                  apt.estado != 'cancelada' &&
                  apt.fechaHora.isBefore(DateTime.now()))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Citas próximas
              if (upcomingAppointments.isNotEmpty) ...[
                Text(
                  'Próximas Citas',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                ...upcomingAppointments
                    .map((apt) => _buildAppointmentCard(apt, context, isDoctor)),
                const SizedBox(height: 24),
              ],

              // Citas pasadas
              if (pastAppointments.isNotEmpty) ...[
                Text(
                  'Citas Pasadas',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                ...pastAppointments
                    .map((apt) => _buildAppointmentCard(apt, context, isDoctor)),
                const SizedBox(height: 24),
              ],
            ],
          );
        },
      ),
      floatingActionButton: !isDoctor
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookAppointmentScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva Cita'),
              backgroundColor: Colors.blue[700],
            )
          : null,
    );
  }

  Widget _buildAppointmentCard(
      AppointmentModel appointment, BuildContext context, bool isDoctor) {
    final isPast = appointment.fechaHora.isBefore(DateTime.now());
    final isCancelled = appointment.estado == 'cancelada';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isCancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Cancelada';
    } else if (appointment.estado == 'confirmada') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Confirmada';
    } else if (isPast) {
      statusColor = Colors.grey;
      statusIcon = Icons.history;
      statusText = 'Completada';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = 'Pendiente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailScreen(appointment: appointment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!isCancelled && !isPast)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit' && !isDoctor) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditAppointmentScreen(
                                appointment: appointment,
                              ),
                            ),
                          );
                        } else if (value == 'cancel') {
                          _showCancelDialog(context, appointment);
                        } else if (value == 'confirm' && isDoctor) {
                          _confirmAppointment(context, appointment);
                        }
                      },
                      itemBuilder: (context) => [
                        if (isDoctor && appointment.estado == 'pendiente')
                          const PopupMenuItem(
                            value: 'confirm',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 20, color: Colors.green),
                                SizedBox(width: 12),
                                Text('Confirmar', style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        if (!isDoctor)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 12),
                                Text('Editar'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Cancelar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Información del paciente/doctor
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDoctor ? Icons.person : Icons.medical_services,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<UserModel?>(
                      future: isDoctor
                          ? _firestoreService.getUser(appointment.pacienteId)
                          : _firestoreService.getUser(appointment.medicoId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: 100,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 12,
                                width: 150,
                                color: Colors.grey[200],
                              ),
                            ],
                          );
                        }

                        final person = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDoctor
                                  ? person?.nombre ?? 'Paciente'
                                  : 'Dr. ${person?.nombre ?? 'Doctor'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              isDoctor
                                  ? appointment.motivo
                                  : person?.especialidad ?? 'Especialista',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fecha y hora
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(appointment.fechaHora),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('hh:mm a').format(appointment.fechaHora),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 12),
            const Text('Cancelar Cita'),
          ],
        ),
        content: Text(
          '¿Estás seguro que deseas cancelar esta cita?\n\nFecha: ${DateFormat('dd/MM/yyyy').format(appointment.fechaHora)}\nHora: ${DateFormat('hh:mm a').format(appointment.fechaHora)}',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.cancelAppointment(appointment.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita cancelada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAppointment(
      BuildContext context, AppointmentModel appointment) async {
    try {
      await _firestoreService.updateAppointment(
        appointment.id!,
        {'estado': 'confirmada'},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita confirmada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al confirmar cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}