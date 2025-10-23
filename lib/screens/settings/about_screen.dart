import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sobre nosotros',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_hospital_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DoctorAppointmentApp',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versión 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: '¿Quiénes somos?',
                    content:
                        'DoctorAppointmentApp es una plataforma digital innovadora diseñada para facilitar el acceso a servicios de salud de calidad. Conectamos a pacientes con profesionales médicos de forma rápida, segura y eficiente.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Nuestra Misión',
                    content:
                        'Democratizar el acceso a la atención médica mediante tecnología, haciendo que sea más fácil para las personas encontrar, reservar y gestionar sus citas médicas desde cualquier lugar.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Nuestros Valores',
                    content: '',
                  ),
                  _buildValueItem(
                    icon: Icons.health_and_safety,
                    title: 'Salud Primero',
                    description: 'La salud y bienestar de nuestros usuarios es nuestra prioridad.',
                  ),
                  _buildValueItem(
                    icon: Icons.verified_user,
                    title: 'Confianza',
                    description: 'Trabajamos con profesionales certificados y verificados.',
                  ),
                  _buildValueItem(
                    icon: Icons.phone_android,
                    title: 'Accesibilidad',
                    description: 'Tecnología simple y accesible para todos.',
                  ),
                  _buildValueItem(
                    icon: Icons.lock,
                    title: 'Privacidad',
                    description: 'Protegemos tu información con los más altos estándares.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Contacto',
                    content:
                        'Email: contacto@doctorapp.com\nTeléfono: +52 55 1234 5678\nSitio web: www.doctorapp.com',
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '© 2025 DoctorAppointmentApp\nTodos los derechos reservados',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildValueItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}