import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Task> tasks;
  const StatisticsScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isDone).length;
    final pending = total - completed;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: total == 0
            ? const Center(child: Text('Aucune tâche disponible'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition des tâches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 📊 PIE CHART
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: completed.toDouble(),
                      title: '$completed',
                      color: Colors.green,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: pending.toDouble(),
                      title: '$pending',
                      color: Colors.orange,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🧾 Légende
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Legend(color: Colors.green, text: 'Complétées'),
                SizedBox(width: 16),
                Legend(color: Colors.orange, text: 'En cours'),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Comparaison',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 📊 BAR CHART
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: completed.toDouble(),
                          color: Colors.green,
                          width: 30,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: pending.toDouble(),
                          color: Colors.orange,
                          width: 30,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Faites');
                            case 1:
                              return const Text('En cours');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🧩 Widget légende
class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
