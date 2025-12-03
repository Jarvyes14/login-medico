import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
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

  UserModel? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos existentes
    _selectedDate = widget.appointment.fechaHora;
    _selectedTime = TimeOfDay(
      hour: widget.appointment.fechaHora.hour,
      minute: widget.appointment.fechaHora.minute,
    );
    _motivoController.text = widget.appointment.motivo;
    
    // Cargar el doctor actual
    _loadCurrentDoctor();
  }

  Future<void> _loadCurrentDoctor() async {
    final doctor = await _firestoreService.getUser(widget.appointment.medicoId);
    if (doctor != null && mounted) {
      setState(() {
        _selectedDoctor = doctor;
      });
    }
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
              onPrimary: Colors.white,
              onSurface: Colors.black,
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

  Future<bool> _checkTimeAvailability(
      DateTime selectedDate, TimeOfDay selectedTime) async {
    try {
      final selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final dateString =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

      final querySnapshot = await _firestoreService.instance
          .collection('citas')
          .where('date', isEqualTo: dateString)
          .get();

      for (var doc in querySnapshot.docs) {
        // Excluir la cita actual de la verificación
        if (doc.id == widget.appointment.id) continue;

        final data = doc.data();
        final existingTime = data['time'] as String;

        final timeParts = existingTime.split(':');
        final existingDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        final difference =
            selectedDateTime.difference(existingDateTime).inMinutes;

        if (difference.abs() < 60) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error al verificar disponibilidad: $e');
      return false;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue[700]!,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      // Validar horario permitido (7:00 AM - 1:00 PM)
      final pickedMinutes = picked.hour * 60 + picked.minute;
      final minTime = 7 * 60;
      final maxTime = 13 * 60;

      if (pickedMinutes < minTime || pickedMinutes > maxTime) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  const Text('Horario no permitido'),
                ],
              ),
              content: Text(
                'Las citas solo pueden agendarse entre las 7:00 AM y la 1:00 PM.\n\n'
                'Esto permite que la última cita termine como máximo a las 2:00 PM.',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (_selectedDate != null) {
        setState(() {
          _isCheckingAvailability = true;
        });

        final isAvailable =
            await _checkTimeAvailability(_selectedDate!, picked);

        setState(() {
          _isCheckingAvailability = false;
        });

        if (isAvailable) {
          setState(() {
            _selectedTime = picked;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Horario disponible: ${picked.format(context)}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Text('Horario no disponible'),
                  ],
                ),
                content: Text(
                  'Ya existe una cita en ese horario o dentro de los 60 minutos siguientes. '
                  'Por favor, selecciona otro horario.',
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona primero una fecha'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _updateAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedDoctor != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      setState(() => _isLoading = true);

      final fechaHora = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      try {
        await _firestoreService.updateAppointment(
          widget.appointment.id!,
          {
            'medico_id': _selectedDoctor!.uid,
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

              // Selector de doctor
              Text(
                'Doctor',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<UserModel>>(
                stream: _firestoreService.getAllDoctors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final doctors = snapshot.data ?? [];

                  // Eliminar duplicados basándose en el UID
                  final uniqueDoctors = <String, UserModel>{};
                  for (var doctor in doctors) {
                    uniqueDoctors[doctor.uid] = doctor;
                  }
                  final doctorsList = uniqueDoctors.values.toList();

                  if (doctorsList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Text(
                        'No hay doctores disponibles',
                        style: GoogleFonts.poppins(color: Colors.orange[900]),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Selecciona un doctor'),
                        value: _selectedDoctor != null &&
                                doctorsList
                                    .any((d) => d.uid == _selectedDoctor!.uid)
                            ? _selectedDoctor!.uid
                            : null,
                        items: doctorsList.map((doctor) {
                          return DropdownMenuItem<String>(
                            value: doctor.uid,
                            child: Row(
                              children: [
                                Icon(Icons.person,
                                    color: Colors.blue[700], size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Dr. ${doctor.nombre}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        doctor.especialidad ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? uid) {
                          if (uid != null) {
                            final doctor = doctorsList
                                .firstWhere((d) => d.uid == uid);
                            setState(() {
                              _selectedDoctor = doctor;
                            });
                          }
                        },
                      ),
                    ),
                  );
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
                'Hora de la cita',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _isCheckingAvailability
                    ? null
                    : () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isCheckingAvailability
                          ? Colors.grey[400]!
                          : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _isCheckingAvailability
                        ? Colors.grey[100]
                        : Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      _isCheckingAvailability
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[700]!),
                              ),
                            )
                          : Icon(Icons.access_time, color: Colors.grey[700]),
                      const SizedBox(width: 12),
                      Text(
                        _isCheckingAvailability
                            ? 'Verificando disponibilidad...'
                            : _selectedTime == null
                                ? 'Selecciona una hora'
                                : _selectedTime!.format(context),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _isCheckingAvailability
                              ? Colors.grey[600]
                              : _selectedTime == null
                                  ? Colors.grey[600]
                                  : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
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