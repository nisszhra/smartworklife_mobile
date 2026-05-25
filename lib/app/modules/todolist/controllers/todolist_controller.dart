import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/models/todo_model.dart';
import 'package:worklife_mobile/app/data/repositories/todo_repository.dart';

// Re-export TodoModel agar view bisa import dari sini (backward compat)
export 'package:worklife_mobile/app/data/models/todo_model.dart';

// ─── Controller ─────────────────────────────────────────────────────────────
class TodolistController extends GetxController {
  final TodoRepository _repository;

  TodolistController(this._repository);

  final tasks = <TodoModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isCompletedExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  // ── Ambil semua tugas dari backend ─────────────────────────────────────────
  Future<void> fetchTodos() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.getTodos();
      tasks.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Tambah tugas ───────────────────────────────────────────────────────────
  Future<void> addTask({
    required String title,
    String description = '',
    bool isPriority = false,
    DateTime? deadline,
    String? taskDate,
  }) async {
    try {
      final newTask = await _repository.createTodo(
        title: title,
        description: description.isNotEmpty ? description : null,
        priority: isPriority ? 'important' : 'normal',
        deadline: deadline,
        taskDate: taskDate,
      );
      tasks.insert(0, newTask);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Update tugas ───────────────────────────────────────────────────────────
  Future<void> updateTask({
    required String id,
    required String title,
    String description = '',
    bool? isPriority,
    DateTime? deadline,
    String? taskDate,
  }) async {
    try {
      final updated = await _repository.updateTodo(
        id,
        title: title,
        description: description.isNotEmpty ? description : null,
        priority: isPriority != null
            ? (isPriority ? 'important' : 'normal')
            : null,
        deadline: deadline,
        taskDate: taskDate,
      );
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = updated;
        tasks.refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Hapus tugas ────────────────────────────────────────────────────────────
  Future<void> deleteTask(String id) async {
    // Optimistic: hapus dulu dari UI
    final index = tasks.indexWhere((t) => t.id == id);
    TodoModel? removed;
    if (index != -1) {
      removed = tasks[index];
      tasks.removeAt(index);
    }

    try {
      await _repository.deleteTodo(id);
    } catch (e) {
      // Rollback jika gagal
      if (removed != null) tasks.insert(index, removed);
      Get.snackbar(
        'Gagal menghapus',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Toggle selesai / belum ─────────────────────────────────────────────────
  Future<void> toggleTaskStatus(String id) async {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final currentTask = tasks[index];
    final newStatus = currentTask.isCompleted ? 'pending' : 'done';

    // Optimistic update
    tasks[index] = currentTask.copyWith(status: newStatus);
    tasks.refresh();

    try {
      final updated = await _repository.updateTodo(id, status: newStatus);
      tasks[index] = updated;
      tasks.refresh();
    } catch (e) {
      // Rollback
      tasks[index] = currentTask;
      tasks.refresh();
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}