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

    // Comptage par catégorie
    final categories = ['Travail', 'Personnel', 'Urgent'];
    final categoryCounts = categories.map((c) => tasks.where((t) => t.category == c).length).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tâches totales : $total', style: const TextStyle(fontSize: 16)),
              Text('Tâches complétées : $completed', style: const TextStyle(fontSize: 16)),
              Text('Tâches en cours : $pending', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              // Pie Chart : complétées / en cours
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: pending.toDouble(),
                        color: Colors.red,
                        title: '${((pending / total) * 100).toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: completed.toDouble(),
                        color: Colors.green,
                        title: '${((completed / total) * 100).toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Complétées'),
                  SizedBox(width: 16),
                  Icon(Icons.circle, color: Colors.red, size: 16),
                  SizedBox(width: 4),
                  Text('En cours'),
                ],
              ),
              const SizedBox(height: 40),

              const Text('Tâches par catégorie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Bar Chart par catégorie
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: categoryCounts.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < categories.length) {
                              return Text(categories[index]);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(categories.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: categoryCounts[i].toDouble(),
                            color: Colors.blue,
                            width: 20,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

