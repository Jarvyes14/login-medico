import 'package:doctor_appointment_app/screens/doctor/doctor_charts_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart'; // Asegúrate de tener este archivo
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/doctor/doctors_list_screen.dart';
import 'screens/doctor/doctor_profile_screen.dart';
import 'screens/appointment/appointments_list_screen.dart';
import 'screens/appointment/book_appointment_screen.dart';
import 'screens/appointment/appointment_detail_screen.dart';
import 'models/user_model.dart';
import 'models/appointment_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase con las opciones configuradas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Appointment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/doctors-list': (context) => const DoctorsListScreen(),
        '/appointments': (context) => const AppointmentsListScreen(),
        '/charts': (_) => const DoctorChartsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/doctor-profile') {
          final doctor = settings.arguments as UserModel;
          return MaterialPageRoute(
            builder: (context) => DoctorProfileScreen(doctor: doctor),
          );
        }
        
        if (settings.name == '/book-appointment') {
          final doctor = settings.arguments as UserModel?;
          return MaterialPageRoute(
            builder: (context) => BookAppointmentScreen(
              preselectedDoctor: doctor,
            ),
          );
        }
        
        if (settings.name == '/appointment-detail') {
          final appointment = settings.arguments as AppointmentModel;
          return MaterialPageRoute(
            builder: (context) => AppointmentDetailScreen(
              appointment: appointment,
            ),
          );
        }
        
        return null;
      },
    );
  }
}