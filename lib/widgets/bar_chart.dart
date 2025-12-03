import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Misma lógica de agrupación que el Pie, pero dibujado con barras.
class AppointmentsByDayBarChart extends StatelessWidget {
  final Stream<List<dynamic>> appointmentsStream;
  const AppointmentsByDayBarChart({Key? key, required this.appointmentsStream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: appointmentsStream,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

        final appointments = snap.data!;

        // --- 1. Contar por día de la semana ---
        final counts = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
        for (var apt in appointments) {
          final date = apt.fechaHora as DateTime;
          counts[date.weekday] = (counts[date.weekday] ?? 0) + 1;
        }

        // --- 2. Preparar datos para el gráfico ---
        final week = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final colors = [
          Colors.blue, Colors.indigo, Colors.teal,
          Colors.green, Colors.yellow, Colors.orange, Colors.red
        ];

        final barGroups = <BarChartGroupData>[];
        for (int i = 1; i <= 7; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i]!.toDouble(),
                  color: colors[i - 1],
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }

        if (appointments.isEmpty) {
          return const Center(child: Text('No hay citas para mostrar'));
        }

        // --- 3. Dibujar ---
        return SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) =>
                        Text(week[value.toInt() - 1]),
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }
}