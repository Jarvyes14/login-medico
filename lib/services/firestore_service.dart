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

  // NUEVO: Actualizar cita
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
}