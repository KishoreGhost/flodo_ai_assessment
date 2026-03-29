import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/task_model.dart';

class TaskRepository {
  late final Dio _dio;

  TaskRepository() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<List<Task>> getTasks({String? q}) async {
    final response = await _dio.get(
      '/tasks',
      queryParameters: (q != null && q.isNotEmpty) ? {'q': q} : null,
    );
    return (response.data as List)
        .map((j) => Task.fromJson(j as Map<String, dynamic>))
        .toList();
  }



  Future<Task> createTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    TaskStatus status = TaskStatus.todo,
    int? blockedById,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status.value,
      if (dueDate != null)
        'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      if (blockedById != null) 'blocked_by_id': blockedById,
    };
    final response = await _dio.post('/tasks', data: body);
    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> updates) async {
    if (updates['due_date'] is DateTime) {
      updates['due_date'] =
          DateFormat('yyyy-MM-dd').format(updates['due_date'] as DateTime);
    }
    final response = await _dio.put('/tasks/$id', data: updates);
    return Task.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    await _dio.delete('/tasks/$id');
  }

  Future<void> reorderTasks(List<Map<String, int>> items) async {
    await _dio.patch('/tasks/reorder', data: items);
  }
}
