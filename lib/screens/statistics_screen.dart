import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task.dart';
import '../controllers/statistics_controller.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Task> tasks;

  const StatisticsScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final controller = StatisticsController();
    final stats = controller.calculateStats(tasks);

    final total = stats['total'];
    final completed = stats['completed'];
    final pending = stats['pending'];
    final percentCompleted = stats['percentCompleted'];
    final percentPending = stats['percentPending'];
    final categories = stats['categories'];
    final Map<String, int> categoryCounts =
    Map<String, int>.from(stats['categoryCounts']);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            //CARD STATS
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _statRow('Total', total),
                    _statRow('Complétées', completed),
                    _statRow('En cours', pending),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // PIE CHART
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Progression',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: pending.toDouble(),
                                  color: Colors.orange,
                                  title:
                                  '${percentPending.toStringAsFixed(1)}%',
                                  radius: 60,
                                ),
                                PieChartSectionData(
                                  value: completed.toDouble(),
                                  color: Colors.green,
                                  title:
                                  '${percentCompleted.toStringAsFixed(1)}%',
                                  radius: 60,
                                ),
                              ],
                              centerSpaceRadius: 50,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                            ),
                          ),

                          // Texte ct
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Total'),
                              Text('$total',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.circle, color: Colors.green, size: 12),
                        SizedBox(width: 4),
                        Text('Complétées'),
                        SizedBox(width: 16),
                        Icon(Icons.circle, color: Colors.orange, size: 12),
                        SizedBox(width: 4),
                        Text('En cours'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // BAR CHART
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Par catégorie',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (categoryCounts.values.isEmpty
                              ? 0
                              : categoryCounts.values.reduce(
                                  (a, b) => a > b ? a : b))
                              .toDouble() +
                              1,
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
                                  if (index >= 0 &&
                                      index < categories.length) {
                                    return Text(categories[index]);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups:
                          List.generate(categories.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY:
                                  categoryCounts[categories[i]]!
                                      .toDouble(),
                                  width: 20,
                                  borderRadius:
                                  BorderRadius.circular(6),
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
          ],
        ),
      ),
    );
  }

  Widget _statRow(String title, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value.toString(),
              style:
              const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}