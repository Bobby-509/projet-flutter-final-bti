import '../models/task.dart';

class StatisticsController {
  Map<String, dynamic> calculateStats(List<Task> tasks) {

    final total = tasks.length;
    final completed = tasks.where((t) => t.isDone).length;
    final pending = total - completed;

    final percentCompleted = total == 0 ? 0.0 : (completed / total) * 100;
    final percentPending = total == 0 ? 0.0 : (pending / total) * 100;

    final categories = ['Travail', 'Personnel', 'Urgent'];

    final Map<String, int> categoryCounts = Map<String, int>.from(
      {
        for (var c in categories)
          c: tasks.where((t) => t.category == c).length
      },
    );

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'percentCompleted': percentCompleted,
      'percentPending': percentPending,
      'categories': categories,
      'categoryCounts': categoryCounts,
    };
  }
}