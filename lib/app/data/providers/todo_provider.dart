import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/services/dio_service.dart';

/// Raw HTTP calls ke endpoint /todos/*.
/// Tidak mengandung business logic — hanya melempar request dan return Response.
class TodoProvider {
  TodoProvider();

  dio.Dio get _dio => Get.find<DioService>().client;

  /// GET /todos/?category=all
  Future<dio.Response> getTodos({
    String category = 'all',
    String? statusFilter,
  }) {
    return _dio.get(
      '/todos/',
      queryParameters: {
        'category': category,
        if (statusFilter != null) 'status': statusFilter,
      },
    );
  }

  /// POST /todos/
  Future<dio.Response> createTodo({
    required String title,
    String? description,
    required String priority, // "important" | "normal"
    DateTime? deadline,
    String? taskDate, // format: "yyyy-MM-dd"
  }) {
    return _dio.post('/todos/', data: {
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'priority': priority,
      if (deadline != null) 'deadline': deadline.toUtc().toIso8601String(),
      if (taskDate != null) 'task_date': taskDate,
    });
  }

  /// PATCH /todos/{id}
  Future<dio.Response> updateTodo(
    String todoId, {
    String? title,
    String? description,
    String? priority,
    String? status, // "pending" | "done"
    DateTime? deadline,
    String? taskDate,
  }) {
    return _dio.patch('/todos/$todoId', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (deadline != null) 'deadline': deadline.toUtc().toIso8601String(),
      if (taskDate != null) 'task_date': taskDate,
    });
  }

  /// DELETE /todos/{id}
  Future<dio.Response> deleteTodo(String todoId) {
    return _dio.delete('/todos/$todoId');
  }
}
