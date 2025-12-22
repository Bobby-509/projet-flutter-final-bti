import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Travail';

  DateTime? _selectedDateTime;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedCategory = widget.task!.category;
      _selectedDateTime = widget.task!.dueDate;
      if (_selectedDateTime != null) {
        _dateController.text =
        '${_selectedDateTime!.day.toString().padLeft(2, '0')}/'
            '${_selectedDateTime!.month.toString().padLeft(2, '0')}/'
            '${_selectedDateTime!.year}';
        _timeController.text =
        '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:'
            '${_selectedDateTime!.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        final hour = _selectedDateTime?.hour ?? 0;
        final minute = _selectedDateTime?.minute ?? 0;
        _selectedDateTime =
            DateTime(pickedDate.year, pickedDate.month, pickedDate.day, hour, minute);
        _dateController.text =
        '${pickedDate.day.toString().padLeft(2, '0')}/'
            '${pickedDate.month.toString().padLeft(2, '0')}/'
            '${pickedDate.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    if (_selectedDateTime == null) return; // Empêche si pas de date

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime!),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime!.year,
          _selectedDateTime!.month,
          _selectedDateTime!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _timeController.text =
        '${pickedTime.hour.toString().padLeft(2, '0')}:'
            '${pickedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _resetDate() {
    setState(() {
      _selectedDateTime = null;
      _dateController.clear();
      _timeController.clear();
    });
  }

  void _resetTime() {
    setState(() {
      if (_selectedDateTime != null) {
        _selectedDateTime = DateTime(
          _selectedDateTime!.year,
          _selectedDateTime!.month,
          _selectedDateTime!.day,
        );
      }
      _timeController.clear();
    });
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        dueDate: _selectedDateTime,
        isDone: widget.task?.isDone ?? false,
      );

      if (widget.task == null) {
        await DatabaseService.instance.insertTask(task);
      } else {
        await DatabaseService.instance.updateTask(task);
      }

      Navigator.pop(context, true);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nouvelle tâche' : 'Modifier tâche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Champ obligatoire' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Travail', 'Personnel', 'Urgent']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
                decoration: const InputDecoration(labelText: 'Catégorie'),
              ),
              const SizedBox(height: 12),

              // Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date d’échéance',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_dateController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _resetDate,
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Heure
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Heure d’échéance',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_timeController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _resetTime,
                        ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: _selectedDateTime != null ? _pickTime : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton enregistrer
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
