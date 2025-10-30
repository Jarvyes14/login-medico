import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../services/firestore_service.dart';
import 'edit_appointment_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPast = appointment.fechaHora.isBefore(DateTime.now());
    final isCancelled = appointment.estado == 'cancelada';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle de Cita',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isCancelled && !isPast)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditAppointmentScreen(
                      appointment: appointment,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con estado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCancelled
                      ? [Colors.red[400]!, Colors.red[600]!]
                      : isPast
                          ? [Colors.grey[400]!, Colors.grey[600]!]
                          : [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isCancelled
                        ? Icons.cancel
                        : isPast
                            ? Icons.check_circle
                            : Icons.event_available,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCancelled
                        ? 'Cita Cancelada'
                        : isPast
                            ? 'Cita Completada'
                            : 'Cita Agendada',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Información detallada
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    icon: Icons.medical_services,
                    title: 'Especialidad',
                    content: appointment.medicoId,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.calendar_today,
                    title: 'Fecha',
                    content: DateFormat('EEEE, dd MMMM yyyy', 'es')
                        .format(appointment.fechaHora),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.access_time,
                    title: 'Hora',
                    content: DateFormat('hh:mm a').format(appointment.fechaHora),
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.description,
                    title: 'Motivo de Consulta',
                    content: appointment.motivo,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.info_outline,
                    title: 'Estado',
                    content: _getEstadoText(appointment.estado),
                    color: _getEstadoColor(appointment.estado),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    icon: Icons.create,
                    title: 'Fecha de Registro',
                    content: DateFormat('dd/MM/yyyy hh:mm a')
                        .format(appointment.createdAt),
                    color: Colors.grey,
                  ),

                  // Instrucciones previas
                  if (!isCancelled && !isPast) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              Text(
                                'Instrucciones Previas',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInstruction('Llega 15 minutos antes'),
                          _buildInstruction('Trae tu identificación oficial'),
                          _buildInstruction('Trae estudios médicos previos'),
                          _buildInstruction(
                              'Lista de medicamentos que tomas actualmente'),
                        ],
                      ),
                    ),
                  ],

                  // Botones de acción
                  if (!isCancelled && !isPast) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditAppointmentScreen(
                                    appointment: appointment,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.blue[700]!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCancelDialog(context),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCancelDialog(BuildContext context) {
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
          '¿Estás seguro que deseas cancelar esta cita?\n\nEsta acción no se puede deshacer y el horario quedará disponible para otros pacientes.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () async {
              final firestoreService = FirestoreService();
              await firestoreService.cancelAppointment(appointment.id!);
              
              if (context.mounted) {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Regresar a lista
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
            child: const Text('Sí, cancelar cita'),
          ),
        ],
      ),
    );
  }
}