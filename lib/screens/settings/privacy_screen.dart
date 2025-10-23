import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacidad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.shield_outlined,
              title: 'Política de Privacidad',
              content:
                  'En DoctorAppointmentApp, nos comprometemos a proteger tu privacidad y la seguridad de tus datos personales. Toda la información que compartes con nosotros se maneja con los más altos estándares de seguridad.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.lock_outline,
              title: 'Seguridad de Datos',
              content:
                  'Utilizamos cifrado de extremo a extremo para proteger tu información médica y personal. Tus datos están almacenados en servidores seguros con Firebase, cumpliendo con todas las normativas de protección de datos.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.visibility_off_outlined,
              title: 'Confidencialidad',
              content:
                  'Tu historial médico y citas son completamente confidenciales. Solo tú y los profesionales de la salud autorizados tienen acceso a esta información.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.delete_outline,
              title: 'Tus Derechos',
              content:
                  'Tienes derecho a acceder, modificar o eliminar tus datos personales en cualquier momento. Puedes solicitar una copia de tu información o la eliminación completa de tu cuenta.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Para más información, contáctanos en:\nprivacidad@doctorapp.com',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.blue[900],
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue[700], size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
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
    );
  }
}