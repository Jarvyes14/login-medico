import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String? id;
  final String pacienteId;
  final String medicoId;
  final DateTime fechaHora;
  final String motivo;
  final String estado; // 'pendiente', 'confirmada', 'cancelada'
  final DateTime createdAt;

  AppointmentModel({
    this.id,
    required this.pacienteId,
    required this.medicoId,
    required this.fechaHora,
    required this.motivo,
    this.estado = 'pendiente',
    required this.createdAt,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      pacienteId: data['paciente_id'] ?? '',
      medicoId: data['medico_id'] ?? '',
      fechaHora: (data['fecha_hora'] as Timestamp).toDate(),
      motivo: data['motivo'] ?? '',
      estado: data['estado'] ?? 'pendiente',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'paciente_id': pacienteId,
      'medico_id': medicoId,
      'fecha_hora': Timestamp.fromDate(fechaHora),
      'motivo': motivo,
      'estado': estado,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}