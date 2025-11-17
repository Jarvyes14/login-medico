import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/appointment_model.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = _authService.currentUser;
    if (user != null) {
      final stats = await _firestoreService.getDoctorStats(user.uid);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjetas de estadísticas
                    Text(
                      'Resumen de Citas',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            _stats?['total']?.toString() ?? '0',
                            Icons.calendar_month,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pendientes',
                            _stats?['pendientes']?.toString() ?? '0',
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Confirmadas',
                            _stats?['confirmadas']?.toString() ?? '0',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Canceladas',
                            _stats?['canceladas']?.toString() ?? '0',
                            Icons.cancel,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Próximas citas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Próximas Citas',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            // Navegar a la lista completa de citas
                            Navigator.pushNamed(context, '/appointments');
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Ver todas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stream de citas del doctor
                    StreamBuilder<List<AppointmentModel>>(
                      stream: _firestoreService.getDoctorAppointments(user!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final appointments = snapshot.data ?? [];
                        
                        // Filtrar solo las próximas (no canceladas y futuras)
                        final upcomingAppointments = appointments
                            .where((apt) =>
                                apt.estado != 'cancelada' &&
                                apt.fechaHora.isAfter(DateTime.now()))
                            .take(5)
                            .toList();

                        if (upcomingAppointments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tienes citas próximas',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: upcomingAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = upcomingAppointments[index];
                            return _buildAppointmentCard(appointment);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final dateStr =
        '${appointment.fechaHora.day}/${appointment.fechaHora.month}/${appointment.fechaHora.year}';
    final timeStr =
        '${appointment.fechaHora.hour.toString().padLeft(2, '0')}:${appointment.fechaHora.minute.toString().padLeft(2, '0')}';

    Color statusColor;
    String statusText;
    switch (appointment.estado) {
      case 'confirmada':
        statusColor = Colors.green;
        statusText = 'Confirmada';
        break;
      case 'cancelada':
        statusColor = Colors.red;
        statusText = 'Cancelada';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.event, color: Colors.blue[700]),
        ),
        title: FutureBuilder(
          future: _firestoreService.getUser(appointment.pacienteId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data?.nombre ?? 'Paciente',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              );
            }
            return const Text('Cargando...');
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('$dateStr - $timeStr'),
            const SizedBox(height: 4),
            Text(
              appointment.motivo,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // Navegar a detalles de la cita
          Navigator.pushNamed(
            context,
            '/appointment-detail',
            arguments: appointment,
          );
        },
      ),
    );
  }
}