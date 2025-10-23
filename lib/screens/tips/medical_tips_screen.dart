import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicalTipsScreen extends StatelessWidget {
  const MedicalTipsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Consejos Médicos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            icon: Icons.headset_mic,
            title: 'Dolor de Cabeza',
            color: Colors.purple,
            tips: [
              'Descansa en un lugar tranquilo y oscuro',
              'Aplica compresas frías en la frente',
              'Mantente hidratado bebiendo agua',
              'Evita pantallas y luces brillantes',
              'Si el dolor persiste más de 2 días, consulta a un médico',
            ],
          ),
          _buildTipCard(
            icon: Icons.favorite,
            title: 'Dolor de Estómago',
            color: Colors.orange,
            tips: [
              'Evita alimentos pesados y grasosos',
              'Bebe té de manzanilla o menta',
              'Come en porciones pequeñas',
              'Evita acostarte inmediatamente después de comer',
              'Si hay vómito o fiebre, busca atención médica',
            ],
          ),
          _buildTipCard(
            icon: Icons.thermostat,
            title: 'Fiebre Leve',
            color: Colors.red,
            tips: [
              'Mantente hidratado con agua y líquidos',
              'Descansa lo suficiente',
              'Usa ropa ligera y cómoda',
              'Aplica compresas tibias (no frías)',
              'Si la fiebre supera 39°C, consulta al médico',
            ],
          ),
          _buildTipCard(
            icon: Icons.air,
            title: 'Resfriado Común',
            color: Colors.blue,
            tips: [
              'Descansa y duerme lo suficiente',
              'Bebe líquidos calientes como té o sopa',
              'Haz gárgaras con agua tibia y sal',
              'Usa un humidificador en tu habitación',
              'Lávate las manos frecuentemente',
            ],
          ),
          _buildTipCard(
            icon: Icons.psychology,
            title: 'Estrés y Ansiedad',
            color: Colors.teal,
            tips: [
              'Practica técnicas de respiración profunda',
              'Realiza ejercicio físico regularmente',
              'Mantén una rutina de sueño saludable',
              'Habla con alguien de confianza',
              'Considera practicar meditación o yoga',
            ],
          ),
          _buildTipCard(
            icon: Icons.local_pharmacy,
            title: 'Dolor Muscular',
            color: Colors.green,
            tips: [
              'Aplica hielo las primeras 48 horas',
              'Después aplica calor con compresas tibias',
              'Estira suavemente los músculos',
              'Descansa y evita actividades intensas',
              'Mantén una buena postura',
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recuerda: Estos son consejos para dolores leves. Si los síntomas persisten o empeoran, consulta a un profesional de la salud.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.red[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> tips,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}