// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:doctor_appointment_app/widgets/bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/pie_chart.dart';

class DoctorChartsScreen extends StatelessWidget {
  const DoctorChartsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();          // ← tu clase
    final _firestoreService = FirestoreService();
    final user = _authService.currentUser;       // ← usuario actual

    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Citas por día de la semana',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppointmentsByDayPieChart(
              appointmentsStream:
                  _firestoreService.getDoctorAppointments(user!.uid),
            ),
            const SizedBox(height: 32),

            Text('Citas por día de la semana',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppointmentsByDayBarChart(
              appointmentsStream:
                  _firestoreService.getDoctorAppointments(user.uid),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}