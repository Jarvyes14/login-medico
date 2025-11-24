import 'package:doctor_appointment_app/screens/doctor/doctor_charts_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screen.dart';
import '../tips/medical_tips_screen.dart';
import '../appointment/appointments_list_screen.dart';
import '../doctor/doctor_dashboard_screen.dart';
import '../doctor/doctors_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si es doctor, mostrar navegación diferente
    if (_currentUser?.isDoctor ?? false) {
      switch (_currentIndex) {
        case 0:
          return _buildDoctorHomeContent();
        case 1:
          return const DoctorDashboardScreen();
        case 2:
          return const AppointmentsListScreen();
        case 3:
          return const MessagesScreen();
        case 4:
          return const DoctorChartsScreen();
        case 5:
          return const SettingsScreen();
        default:
          return _buildDoctorHomeContent();
      }
    } else {
      // Navegación para pacientes
      switch (_currentIndex) {
        case 0:
          return _buildPatientHomeContent();
        case 1:
          return const MessagesScreen();
        case 2:
          return const SettingsScreen();
        default:
          return _buildPatientHomeContent();
      }
    }
  }

  // Contenido principal para PACIENTES
  Widget _buildPatientHomeContent() {
    final userName = _currentUser?.nombre ??
        _authService.currentUser?.displayName ??
        'Usuario';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con saludo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $userName!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿En qué podemos ayudarte hoy?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Opciones principales
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    // Ver mis citas
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.event_note,
                        title: 'Mis Citas',
                        color: Colors.purple[700]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppointmentsListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Ver doctores
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.medical_services,
                        title: 'Ver Doctores',
                        color: Colors.green[700]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorsListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Consejos médicos
                _buildFullWidthActionCard(
                  icon: Icons.lightbulb_outline,
                  title: 'Consejos Médicos',
                  color: Colors.orange[700]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicalTipsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sección de Especialistas
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Especialidades',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista horizontal de especialistas
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 24),
              children: [
                _buildSpecialistCard(
                  icon: Icons.favorite,
                  specialty: 'Cardiología',
                  color: Colors.red[400]!,
                ),
                _buildSpecialistCard(
                  icon: Icons.psychology,
                  specialty: 'Neurología',
                  color: Colors.purple[400]!,
                ),
                _buildSpecialistCard(
                  icon: Icons.child_care,
                  specialty: 'Pediatría',
                  color: Colors.orange[400]!,
                ),
                _buildSpecialistCard(
                  icon: Icons.healing,
                  specialty: 'Dermatología',
                  color: Colors.pink[400]!,
                ),
                _buildSpecialistCard(
                  icon: Icons.visibility,
                  specialty: 'Oftalmología',
                  color: Colors.teal[400]!,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sección de Doctores Disponibles (real desde Firestore)
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Doctores Disponibles',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DoctorsListScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Ver todos',
                    style: GoogleFonts.poppins(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de doctores desde Firestore
          StreamBuilder<List<UserModel>>(
            stream: _firestoreService.getAllDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final doctors = snapshot.data ?? [];
              final limitedDoctors = doctors.take(3).toList();

              if (limitedDoctors.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No hay doctores disponibles',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Column(
                  children: limitedDoctors
                      .map((doctor) => _buildRealDoctorCard(doctor))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Contenido principal para DOCTORES
  Widget _buildDoctorHomeContent() {
    final userName = _currentUser?.nombre ??
        _authService.currentUser?.displayName ??
        'Doctor';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con saludo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services,
                        color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. $userName',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _currentUser?.especialidad ?? 'Especialista',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Accesos rápidos para doctores
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        color: Colors.blue[700]!,
                        onTap: () {
                          setState(() => _currentIndex = 1);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.calendar_today,
                        title: 'Mis Citas',
                        color: Colors.purple[700]!,
                        onTap: () {
                          setState(() => _currentIndex = 2);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Información adicional
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido al Panel de Doctor',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Desde aquí puedes gestionar tus citas, ver estadísticas y comunicarte con tus pacientes.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard({
    required IconData icon,
    required String specialty,
    required Color color,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            specialty,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealDoctorCard(UserModel doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navegar al perfil del doctor
          Navigator.pushNamed(context, '/doctor-profile', arguments: doctor);
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: 32, color: Colors.blue[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.nombre}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    doctor.especialidad ?? 'Especialista',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (doctor.telefono != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          doctor.telefono!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Navegación diferente según el tipo de usuario
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: _currentUser?.isDoctor ?? false
          ? _buildDoctorBottomNav()
          : _buildPatientBottomNav(),
    );
  }

  // Bottom Navigation para PACIENTES
  Widget _buildPatientBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }

  // Bottom Navigation para DOCTORES
  Widget _buildDoctorBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey[400],
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.question_answer),
          label: 'Graficos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }
}