import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null &&
        !task.isDone &&
        task.dueDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => onToggle(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                  color: isOverdue ? Colors.red : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isOverdue)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: const Text(
                  'En retard',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            if (task.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14,
                      color: isOverdue ? Colors.red : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate!.day.toString().padLeft(2, '0')}/'
                        '${task.dueDate!.month.toString().padLeft(2, '0')}/'
                        '${task.dueDate!.year}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.access_time,
                      size: 14,
                      color: isOverdue ? Colors.red : Colors.grey[600]),
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
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.label_outline,
                    size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task.category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}