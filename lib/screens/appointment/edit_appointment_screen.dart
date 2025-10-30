import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../services/firestore_service.dart';

class EditAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const EditAppointmentScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _firestoreService = FirestoreService();

  String? _selectedEspecialista;
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isLoading = false;

  final List<String> _especialistas = [
    'Cardiología',
    'Neurología',
    'Pediatría',
    'Dermatología',
    'Oftalmología',
  ];

  final List<String> _horarios = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Cargar datos existentes
    _selectedEspecialista = widget.appointment.medicoId;
    _selectedDate = widget.appointment.fechaHora;
    _selectedTime = DateFormat('hh:mm a').format(widget.appointment.fechaHora);
    _motivoController.text = widget.appointment.motivo;
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedEspecialista != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      setState(() => _isLoading = true);

      // Combinar fecha y hora
      final timeparts = _selectedTime!.split(' ');
      final hourMinute = timeparts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      if (timeparts[1] == 'PM' && hour != 12) {
        hour += 12;
      } else if (timeparts[1] == 'AM' && hour == 12) {
        hour = 0;
      }

      final fechaHora = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

      try {
        await _firestoreService.updateAppointment(
          widget.appointment.id!,
          {
            'medico_id': _selectedEspecialista,
            'fecha_hora': fechaHora,
            'motivo': _motivoController.text,
          },
        );

        setState(() => _isLoading = false);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 32),
                  const SizedBox(width: 12),
                  const Text('¡Cita actualizada!'),
                ],
              ),
              content: Text(
                'Tu cita ha sido actualizada exitosamente.',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Regresar a detalle
                    Navigator.pop(context); // Regresar a lista
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Cita',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Modifica los datos de tu cita. El sistema validará que no se superpongan con otras citas.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Especialista
              Text(
                'Especialidad',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedEspecialista,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.medical_services),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                hint: const Text('Selecciona una especialidad'),
                items: _especialistas.map((especialista) {
                  return DropdownMenuItem(
                    value: especialista,
                    child: Text(especialista),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEspecialista = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una especialidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Fecha
              Text(
                'Fecha',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[700]),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Selecciona una fecha'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedDate == null
                              ? Colors.grey[600]
                              : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Horario
              Text(
                'Horario',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _horarios.map((horario) {
                  final isSelected = _selectedTime == horario;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTime = horario;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[700] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue[700]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        horario,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Motivo
              Text(
                'Motivo de la consulta',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivoController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe brevemente el motivo de tu consulta',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor describe el motivo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón actualizar
              ElevatedButton(
                onPressed: _isLoading ? null : _updateAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Guardar cambios',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}