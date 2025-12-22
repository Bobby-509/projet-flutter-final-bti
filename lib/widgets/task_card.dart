import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        task.dueDate != null && !task.isDone && task.dueDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: isOverdue ? Colors.red : null, // rouge si en retard
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            if (task.dueDate != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate!.day.toString().padLeft(2, '0')}/'
                        '${task.dueDate!.month.toString().padLeft(2, '0')}/'
                        '${task.dueDate!.year} ',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate!.hour.toString().padLeft(2, '0')}:'
                        '${task.dueDate!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              'Catégorie: ${task.category}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
