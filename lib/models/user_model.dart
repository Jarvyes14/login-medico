import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String userType; // 'patient' o 'doctor'
  final int? edad;
  final String? lugarNacimiento;
  final String? padecimientos;
  
  // Campos específicos para doctores
  final String? especialidad;
  final String? cedula;
  final String? telefono;
  final String? descripcion;
  
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.userType,
    this.edad,
    this.lugarNacimiento,
    this.padecimientos,
    this.especialidad,
    this.cedula,
    this.telefono,
    this.descripcion,
    required this.createdAt,
  });

  // Verificar si es doctor
  bool get isDoctor => userType == 'doctor';
  bool get isPatient => userType == 'patient';

  // Convertir de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      userType: data['user_type'] ?? 'patient',
      edad: data['edad'],
      lugarNacimiento: data['lugar_nacimiento'],
      padecimientos: data['padecimientos'],
      especialidad: data['especialidad'],
      cedula: data['cedula'],
      telefono: data['telefono'],
      descripcion: data['descripcion'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'user_type': userType,
      'edad': edad,
      'lugar_nacimiento': lugarNacimiento,
      'padecimientos': padecimientos,
      'especialidad': especialidad,
      'cedula': cedula,
      'telefono': telefono,
      'descripcion': descripcion,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}