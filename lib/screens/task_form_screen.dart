import 'package:flutter/material.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  final TaskController _controller = TaskController();

  String _selectedCategory = 'Travail';
  DateTime? _selectedDateTime;

  bool _isLoading = false;

  final List<String> categories = ['Travail', 'Personnel', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _initTask();
  }

  void _initTask() {
    final task = widget.task;
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedCategory = task.category;
      _selectedDateTime = task.dueDate;

      if (_selectedDateTime != null) {
        _dateController.text = _formatDate(_selectedDateTime!);
        _timeController.text = _formatTime(_selectedDateTime!);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        final time = _selectedDateTime ?? DateTime.now();
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        _dateController.text = _formatDate(_selectedDateTime!);
      });
    }
  }

  Future<void> _pickTime() async {
    if (_selectedDateTime == null) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime!),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime!.year,
          _selectedDateTime!.month,
          _selectedDateTime!.day,
          picked.hour,
          picked.minute,
        );
        _timeController.text = _formatTime(_selectedDateTime!);
      });
    }
  }

  void _resetDateTime() {
    setState(() {
      _selectedDateTime = null;
      _dateController.clear();
      _timeController.clear();
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      dueDate: _selectedDateTime,
      isDone: widget.task?.isDone ?? false,
    );

    try {
      await _controller.saveTask(
        task,
        isUpdate: widget.task != null,
      );

      final message = widget.task == null
          ? 'Tâche ajoutée avec succès'
          : 'Tâche mise à jour avec succès';

      // Retour avec message
      Navigator.pop(context, {
        "success": true,
        "message": message,
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sauvegarde'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(icon),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null
            ? 'Nouvelle tâche'
            : 'Modifier tâche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Titre', Icons.title),
                validator: (v) =>
                v == null || v.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration:
                _inputDecoration('Description', Icons.description),
                maxLines: 3,
                validator: (v) =>
                v == null || v.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories
                    .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v!),
                decoration:
                _inputDecoration('Catégorie', Icons.category),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration:
                _inputDecoration('Date', Icons.calendar_today)
                    .copyWith(
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_dateController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _resetDateTime,
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration:
                _inputDecoration('Heure', Icons.access_time)
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed:
                    _selectedDateTime != null ? _pickTime : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}