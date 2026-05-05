import 'package:get/get.dart';

// ─── Model ──────────────────────────────────────────────────────────────────
class Task {
  String id;
  String title;
  String description;
  String time;
  bool isCompleted;
  bool isPriority; // ← field baru

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.time = '',
    this.isCompleted = false,
    this.isPriority = false, // ← default false agar data lama tetap valid
  });
}

// ─── Controller ─────────────────────────────────────────────────────────────
class TodolistController extends GetxController {
  final tasks = <Task>[
    Task(id: '1', title: 'Laporan Strategi Q4',       description: 'Menyusun laporan target Q4',   time: '14:00'),
    Task(id: '2', title: 'Review Desain Nexus UI',    description: 'Feedback untuk tim desain',    time: '16:30'),
    Task(id: '3', title: 'Update Dokumentasi Produk', description: 'Revisi docs versi 2.1',        time: '10:00'),
    Task(id: '4', title: 'Meeting Mingguan',          description: 'Progress sync mingguan',       time: '09:00', isCompleted: true),
    Task(id: '5', title: 'Kirim Email Invoices',      description: 'Invoices bulan April',         time: 'Kemarin', isCompleted: true),
  ].obs;

  // ── Tambah tugas (named parameters agar konsisten dengan view) ─────────────
  void addTask({
    required String title,
    String description = '',
    String time = '',
    bool isPriority = false,
  }) {
    tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      time: time,
      isPriority: isPriority,
    ));
  }

  // ── Update tugas (named parameters + isPriority) ───────────────────────────
  void updateTask({
    required String id,
    required String title,
    String description = '',
    String time = '',
    bool? isPriority,
  }) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index] = Task(
        id: id,
        title: title,
        description: description,
        time: time,
        isCompleted: tasks[index].isCompleted,
        // Jika isPriority tidak dikirim, pertahankan nilai lama
        isPriority: isPriority ?? tasks[index].isPriority,
      );
    }
  }

  // ── Hapus tugas ────────────────────────────────────────────────────────────
  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
  }

  // ── Toggle selesai / belum ─────────────────────────────────────────────────
  void toggleTaskStatus(String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      tasks.refresh();
    }
  }
}