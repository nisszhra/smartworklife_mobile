import 'package:dio/dio.dart';

import 'package:worklife_mobile/app/data/models/todo_model.dart';
import 'package:worklife_mobile/app/data/providers/todo_provider.dart';

/// Kontrak abstrak TodoRepository.
abstract class TodoRepository {
  Future<List<TodoModel>> getTodos({String category, String? statusFilter});
  Future<TodoModel> createTodo({
    required String title,
    String? description,
    required String priority,
    DateTime? deadline,
    String? taskDate,
  });
  Future<TodoModel> updateTodo(
    String todoId, {
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? deadline,
    String? taskDate,
  });
  Future<void> deleteTodo(String todoId);
}

/// Implementasi konkret menggunakan TodoProvider (Dio).
class TodoRepositoryImpl implements TodoRepository {
  final TodoProvider _provider;

  TodoRepositoryImpl(this._provider);

  @override
  Future<List<TodoModel>> getTodos({
    String category = 'all',
    String? statusFilter,
  }) async {
    try {
      final res = await _provider.getTodos(
        category: category,
        statusFilter: statusFilter,
      );
      final List<dynamic> data = res.data as List<dynamic>;
      return data
          .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<TodoModel> createTodo({
    required String title,
    String? description,
    required String priority,
    DateTime? deadline,
    String? taskDate,
  }) async {
    try {
      final res = await _provider.createTodo(
        title: title,
        description: description,
        priority: priority,
        deadline: deadline,
        taskDate: taskDate,
      );
      return TodoModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<TodoModel> updateTodo(
    String todoId, {
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? deadline,
    String? taskDate,
  }) async {
    try {
      final res = await _provider.updateTodo(
        todoId,
        title: title,
        description: description,
        priority: priority,
        status: status,
        deadline: deadline,
        taskDate: taskDate,
      );
      return TodoModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    try {
      await _provider.deleteTodo(todoId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    print('[TodoRepository] Error: ${e.type} | ${e.message}');
    print('[TodoRepository] Response: ${e.response?.statusCode} - ${e.response?.data}');

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Tidak dapat terhubung ke server.');
    }

    final data = e.response?.data;
    String message = 'Terjadi kesalahan. Silakan coba lagi.';
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      message = data['detail'].toString();
    }
    return Exception(message);
  }
}
