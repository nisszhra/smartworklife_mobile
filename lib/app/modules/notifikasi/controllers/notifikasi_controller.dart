import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:worklife_mobile/app/data/models/notifikasi_model.dart';
import 'package:worklife_mobile/app/data/models/todo_model.dart';
import 'package:worklife_mobile/app/data/repositories/hydration_repository.dart';
import 'package:worklife_mobile/app/data/repositories/todo_repository.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/in_app_notification_service.dart';
import 'package:worklife_mobile/app/data/services/notification_service.dart';
import 'package:worklife_mobile/app/modules/main/controllers/main_controller.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';

class NotifikasiController extends GetxController {
  final TodoRepository _todoRepo;
  final HydrationRepository _hydrationRepo;

  NotifikasiController(this._todoRepo, this._hydrationRepo);

  // Baca langsung dari store global — tidak perlu salinan lokal
  InAppNotificationService get _store => Get.find<InAppNotificationService>();

  RxList<NotifikasiModel> get notifications => _store.notifications;

  final selectedCategory = 'semua'.obs;
  final isLoadingDeadlines = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkHydrationReminders(); 
    _checkTodoDeadlines();
  }

  // ─── Dummy (gambaran visual) ──────────────────────────────────────────────

  // ─── Dummy / Fitur Lama Dihapus ───────────────────────────────────────────
  String _todayDateKey() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  int? _parseTimeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  // ─── Hydration Reminders (Real) ──────────────────────────────────────────

  /// Cek jadwal hidrasi hari ini dari backend.
  /// Tambahkan 1 notif per slot yang sudah lewat namun user belum minum air.
  /// ID unik per slot: 'hydration_YYYYMMDD_HHMM' → tidak duplikat.
  Future<void> _checkHydrationReminders() async {
    try {
      final settings = await _hydrationRepo.getSettings();
      if (!settings.reminderEnabled) return;

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final today = await _hydrationRepo.getTodayHydration(dateStr);

      final now = DateTime.now();
      final nowMins = now.hour * 60 + now.minute;

      // Bangun jadwal dari setting (sama seperti HealthController._generateSchedule)
      final startMins = _parseTimeToMinutes(settings.reminderStartTime);
      final endMins = _parseTimeToMinutes(settings.reminderEndTime);
      if (startMins == null || endMins == null) return;

      final interval = settings.reminderIntervalMinutes;
      if (interval <= 0) return;

      final slots = <int>[]; // daftar slot dalam menit dari midnight
      for (int t = startMins; t <= endMins; t += interval) {
        if (t <= nowMins) slots.add(t); // hanya slot yang sudah lewat
      }
      if (slots.isEmpty) return;

      // Log minum air hari ini (waktu lokal)
      final logTimes = today.logs
          .map(
            (l) => l.loggedAt.toLocal().hour * 60 + l.loggedAt.toLocal().minute,
          )
          .toList();

      for (final slotMins in slots) {
        final slotH = slotMins ~/ 60;
        final slotM = slotMins % 60;
        final slotStr =
            '${slotH.toString().padLeft(2, '0')}${slotM.toString().padLeft(2, '0')}';
        final notifId = 'hydration_${_todayDateKey()}_$slotStr';
        if (_store.notifications.any((n) => n.id == notifId) ||
            _store.isDismissed(notifId))
          continue; // sudah ada atau didelete

        // Cek apakah ada log minum air DI ATAU SETELAH slot ini
        final hasDrunkAfter = logTimes.any((lt) => lt >= slotMins);
        if (hasDrunkAfter) continue; // sudah minum, tidak perlu notif

        final shortfallMl = (today.targetMl - today.consumedMl).clamp(
          0,
          double.infinity,
        );
        final shortfallL = (shortfallMl / 1000).toStringAsFixed(1);

        _store.notifications.insert(
          0,
          NotifikasiModel(
            id: notifId,
            title: 'Waktunya Minum Air!',
            body:
                'Kamu belum minum air sejak pukul '
                '${slotH.toString().padLeft(2, '0')}:${slotM.toString().padLeft(2, '0')}. '
                'Sisa target hari ini: ${shortfallL}L.',
            timestamp: DateTime(now.year, now.month, now.day, slotH, slotM),
            isRead: false,
            category: 'health',
            route: Routes.MAIN,
          ),
        );
      }
    } catch (e) {
      print('[NotifikasiController] Gagal cek hidrasi: $e');
    }
  }

  // ─── Deadline Todos ──────────────────────────────────────────────────────

  /// Ambil todos dari backend, filter yang deadline-nya dalam 24 jam ke depan
  /// atau sudah terlewat (dan belum selesai), lalu tambahkan ke store.
  Future<void> _checkTodoDeadlines() async {
    isLoadingDeadlines.value = true;
    try {
      final todos = await _todoRepo.getTodos(statusFilter: 'pending');
      final now = DateTime.now();
      final threshold = now.add(const Duration(hours: 24));

      final nearDeadline = todos.where((TodoModel t) {
        if (t.deadline == null) return false;
        if (t.isCompleted) return false;
        // Tampilkan jika deadline dalam 24 jam ke depan ATAU sudah lewat
        return t.deadline!.isBefore(threshold);
      }).toList();

      // Urutkan: yang paling dekat deadlinenya duluan
      nearDeadline.sort((a, b) => a.deadline!.compareTo(b.deadline!));

      for (final todo in nearDeadline) {
        _store.addTodoDeadlineNotification(
          todoId: todo.id,
          todoTitle: todo.title,
          deadline: todo.deadline!,
        );
        try {
          if (Get.isRegistered<NotificationService>()) {
            Get.find<NotificationService>().scheduleTodoDeadlineNotification(
              todoId: todo.id,
              todoTitle: todo.title,
              deadline: todo.deadline!,
            );
          }
        } catch (_) {}
      }
    } catch (e) {
      print('[NotifikasiController] Gagal fetch todos: $e');
    } finally {
      isLoadingDeadlines.value = false;
    }
  }

  // ─── Filter ──────────────────────────────────────────────────────────────

  List<NotifikasiModel> get filteredNotifications {
    if (selectedCategory.value == 'semua') return notifications;
    return notifications
        .where((n) => n.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void markAsRead(String id) => _store.markAsRead(id);

  void markAllAsRead() {
    _store.markAllAsRead();
    Get.snackbar(
      'Berhasil',
      'Semua notifikasi telah ditandai sebagai dibaca',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF005AB4),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void deleteNotification(String id) => _store.remove(id);

  void clearAll() {
    _store.clearAll();
    Get.snackbar(
      'Kotak Masuk Bersih',
      'Semua notifikasi berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF717785),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void onNotificationTap(NotifikasiModel notification) {
    markAsRead(notification.id);

    if (notification.route != null) {
      if (notification.route == Routes.MAIN) {
        try {
          final mainController = Get.find<MainController>();
          if (notification.id.startsWith('hydration_')) {
            mainController.changePage(3); // Health
          } else if (notification.title.contains('Peregangan')) {
            mainController.changePage(2); // Stretching
          } else if (notification.title.contains('Fokus')) {
            mainController.changePage(1); // Pomodoro
          }
        } catch (_) {}
        Get.back();
      } else {
        Get.toNamed(notification.route!);
      }
    }
  }
}
