import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';

class BookAppointmentScreen extends StatefulWidget {
  final UserModel? preselectedDoctor;

  const BookAppointmentScreen({Key? key, this.preselectedDoctor})
      : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  UserModel? _selectedDoctor;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.preselectedDoctor;
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<bool> _checkTimeAvailability(
      DateTime selectedDate, TimeOfDay selectedTime) async {
    try {
      // Convertir la hora seleccionada a DateTime
      final selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Formatear fecha para la consulta
      final dateString =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

      // Consultar citas existentes del mismo día
      final querySnapshot = await _firestoreService.instance
          .collection('citas')
          .where('date', isEqualTo: dateString)
          .get();

      // Verificar conflictos de horario
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final existingTime = data['time'] as String; // Formato: "HH:mm"

        // Parsear hora existente
        final timeParts = existingTime.split(':');
        final existingDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        // Calcular diferencia en minutos
        final difference =
            selectedDateTime.difference(existingDateTime).inMinutes;

        // Verificar si hay conflicto (misma hora o dentro de 60 minutos)
        if (difference.abs() < 60) {
          return false; // Horario no disponible
        }
      }

      return true; // Horario disponible
    } catch (e) {
      print('Error al verificar disponibilidad: $e');
      return false;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
      final minTime = 7 * 60; // 7:00 AM
      final maxTime = 13 * 60; // 1:00 PM

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

      setState(() {
        _isCheckingAvailability = true;
      });

      // Verificar disponibilidad
      final isAvailable = await _checkTimeAvailability(_selectedDate, picked);

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
        // Mostrar mensaje de error
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
    }
  }

  Future<void> _bookAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDoctor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona un doctor'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final user = _authService.currentUser;
      if (user != null) {
        final fechaHora = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final appointment = AppointmentModel(
          pacienteId: user.uid,
          medicoId: _selectedDoctor!.uid,
          fechaHora: fechaHora,
          motivo: _motivoController.text,
          estado: 'pendiente',
          createdAt: DateTime.now(),
        );

        final error = await _firestoreService.createAppointment(appointment);

        setState(() => _isLoading = false);

        if (error == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cita agendada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendar Cita',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de doctor
              Text(
                'Seleccionar Doctor',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 12),

              if (_selectedDoctor == null)
                StreamBuilder<List<UserModel>>(
                  stream: _firestoreService.getAllDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final doctors = snapshot.data ?? [];

                    if (doctors.isEmpty) {
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
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<UserModel>(
                          isExpanded: true,
                          hint: const Text('Selecciona un doctor'),
                          value: _selectedDoctor,
                          items: doctors.map((doctor) {
                            return DropdownMenuItem<UserModel>(
                              value: doctor,
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
                          onChanged: (UserModel? value) {
                            setState(() => _selectedDoctor = value);
                          },
                        ),
                      ),
                    );
                  },
                )
              else
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue[50],
                          child: Icon(Icons.person,
                              color: Colors.blue[700], size: 25),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${_selectedDoctor!.nombre}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _selectedDoctor!.especialidad ?? '',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.preselectedDoctor == null)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() => _selectedDoctor = null);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Fecha
              Text(
                'Fecha de la cita',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue[700]),
                      const SizedBox(width: 16),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hora
              Text(
                'Hora de la cita',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _isCheckingAvailability ? null : () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isCheckingAvailability
                          ? Colors.grey[400]!
                          : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _isCheckingAvailability ? Colors.grey[50] : null,
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
                          : Icon(Icons.access_time, color: Colors.blue[700]),
                      const SizedBox(width: 16),
                      Text(
                        _isCheckingAvailability
                            ? 'Verificando disponibilidad...'
                            : _selectedTime.format(context),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _isCheckingAvailability
                              ? Colors.grey[600]
                              : null,
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
                  color: Colors.blue[900],
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
                    return 'Por favor ingresa el motivo de la consulta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón
              ElevatedButton(
                onPressed: _isLoading ? null : _bookAppointment,
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
                        'Agendar Cita',
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