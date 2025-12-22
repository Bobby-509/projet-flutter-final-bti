import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskSearchDelegate extends SearchDelegate<String> {
  final List<Task> allTasks;

  TaskSearchDelegate(this.allTasks);

  @override
  String get searchFieldLabel => 'Rechercher une tâche';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allTasks
        .where(
          (task) =>
          task.title.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();

    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allTasks
        .where(
          (task) =>
          task.title.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();

    return _buildList(suggestions);
  }

  Widget _buildList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('Aucune tâche trouvée'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.category),
          trailing: task.isDone
              ? const Icon(Icons.check, color: Colors.green)
              : null,
          onTap: () => close(context, task.title),
        );
      },
    );
  }
}
