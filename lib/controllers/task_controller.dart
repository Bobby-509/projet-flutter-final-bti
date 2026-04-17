import '../models/task.dart';
import '../services/database_service.dart';

class TaskController {
  Future<void> saveTask(Task task, {bool isUpdate = false}) async {
    try {
      if (isUpdate) {
        await DatabaseService.instance.updateTask(task);
      } else {
        await DatabaseService.instance.insertTask(task);
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde');
    }
  }
}