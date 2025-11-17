import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/doctor_availability_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USUARIOS ============
  
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('usuarios').doc(user.uid).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('usuarios').doc(uid).update(data);
  }

  // ============ CITAS ============
  
  Future<String?> createAppointment(AppointmentModel appointment) async {
    try {
      await _firestore.collection('citas').add(appointment.toFirestore());
      return null;
    } catch (e) {
      return 'Error al crear cita: $e';
    }
  }

  Stream<List<AppointmentModel>> getUserAppointments(String userId) {
    return _firestore
        .collection('citas')
        .where('paciente_id', isEqualTo: userId)
        .orderBy('fecha_hora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  // Actualizar cita
  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('citas').doc(appointmentId).update(data);
    } catch (e) {
      throw Exception('Error al actualizar cita: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _firestore.collection('citas').doc(appointmentId).update({
      'estado': 'cancelada',
    });
  }

  // ============ DISPONIBILIDAD DE MÉDICOS ============
  
  Future<void> createDoctorAvailability(DoctorAvailabilityModel availability) async {
    await _firestore
        .collection('disponibilidad_medicos')
        .add(availability.toFirestore());
  }

  Stream<List<DoctorAvailabilityModel>> getDoctorAvailability(
      String medicoId, DateTime fecha) {
    DateTime startOfDay = DateTime(fecha.year, fecha.month, fecha.day);
    DateTime endOfDay = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

    return _firestore
        .collection('disponibilidad_medicos')
        .where('medico_id', isEqualTo: medicoId)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoctorAvailabilityModel.fromFirestore(doc))
            .toList());
  }

  Future<void> markSlotAsUnavailable(String availabilityId) async {
    await _firestore
        .collection('disponibilidad_medicos')
        .doc(availabilityId)
        .update({'esta_disponible': false});
  }

  // ============ DOCTORES ============
  
  // Obtener todos los doctores
  Stream<List<UserModel>> getAllDoctors() {
    return _firestore
        .collection('usuarios')
        .where('user_type', isEqualTo: 'doctor')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Obtener doctores por especialidad
  Stream<List<UserModel>> getDoctorsBySpecialty(String especialidad) {
    return _firestore
        .collection('usuarios')
        .where('user_type', isEqualTo: 'doctor')
        .where('especialidad', isEqualTo: especialidad)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Obtener citas de un doctor
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection('citas')
        .where('medico_id', isEqualTo: doctorId)
        .orderBy('fecha_hora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  // Obtener estadísticas del doctor
  Future<Map<String, dynamic>> getDoctorStats(String doctorId) async {
    try {
      final citasSnapshot = await _firestore
          .collection('citas')
          .where('medico_id', isEqualTo: doctorId)
          .get();

      int totalCitas = citasSnapshot.docs.length;
      int citasPendientes = citasSnapshot.docs
          .where((doc) => doc.data()['estado'] == 'pendiente')
          .length;
      int citasConfirmadas = citasSnapshot.docs
          .where((doc) => doc.data()['estado'] == 'confirmada')
          .length;
      int citasCanceladas = citasSnapshot.docs
          .where((doc) => doc.data()['estado'] == 'cancelada')
          .length;

      return {
        'total': totalCitas,
        'pendientes': citasPendientes,
        'confirmadas': citasConfirmadas,
        'canceladas': citasCanceladas,
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {
        'total': 0,
        'pendientes': 0,
        'confirmadas': 0,
        'canceladas': 0,
      };
    }
  }
}