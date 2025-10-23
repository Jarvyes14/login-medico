import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final int? edad;
  final String? lugarNacimiento;
  final String? padecimientos;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    this.edad,
    this.lugarNacimiento,
    this.padecimientos,
    required this.createdAt,
  });

  // Convertir de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      edad: data['edad'],
      lugarNacimiento: data['lugar_nacimiento'],
      padecimientos: data['padecimientos'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nombre': nombre,
      'edad': edad,
      'lugar_nacimiento': lugarNacimiento,
      'padecimientos': padecimientos,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}