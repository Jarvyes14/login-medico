import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Recibe un Stream<List<AppointmentModel>> y dibuja el PieChart
class AppointmentsByDayPieChart extends StatelessWidget {
  final Stream<List<dynamic>> appointmentsStream;
  const AppointmentsByDayPieChart({Key? key, required this.appointmentsStream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: appointmentsStream,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final appointments = snap.data!;

        // Contar por día de la semana
        final counts = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
        for (var apt in appointments) {
          final date = apt.fechaHora as DateTime;   // ← ya es DateTime, no Timestamp
          counts[date.weekday] = (counts[date.weekday] ?? 0) + 1;
        }

        // Orden Lunes…Domingo
        final week = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final colors = [
          Colors.blue, Colors.indigo, Colors.teal,
          Colors.green, Colors.yellow, Colors.orange, Colors.red
        ];

        final sections = <PieChartSectionData>[];
        for (int i = 1; i <= 7; i++) {
          final qty = counts[i]!;
          if (qty == 0) continue; // no dibujar vacíos
          sections.add(PieChartSectionData(
            color: colors[i - 1],
            value: qty.toDouble(),
            title: '${week[i - 1]}\n$qty',
            radius: 100,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ));
        }

        if (sections.isEmpty) {
          return const Center(child: Text('No hay citas para mostrar'));
        }

        return SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: sections,
            ),
          ),
        );
      },
    );
  }
}