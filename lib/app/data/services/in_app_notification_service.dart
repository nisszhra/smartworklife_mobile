import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:worklife_mobile/app/data/models/notifikasi_model.dart';
import 'package:worklife_mobile/app/data/services/notification_service.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';

/// Store global untuk notifikasi in-app.
/// Dapat diakses dari controller mana pun via Get.find<InAppNotificationService>().
class InAppNotificationService extends GetxService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final notifications = <NotifikasiModel>[].obs;

  /// ID yang sudah ditambahkan (untuk deduplikasi, misal deadline todo yang sama)
  final Set<String> _addedIds = {};

  /// ID yang secara sengaja di-dismiss (dihapus) oleh user, agar tidak muncul kembali
  final Set<String> _dismissedIds = {};

  bool isDismissed(String id) => _dismissedIds.contains(id);

  Future<InAppNotificationService> init() async {
    await _loadDismissedIds();
    return this;
  }

  Future<void> _loadDismissedIds() async {
    try {
      final jsonStr = await _storage.read(key: 'dismissed_notifications_ids');
      print('[InAppNotificationService] Loaded JSON: $jsonStr');
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _dismissedIds.addAll(decoded.cast<String>());
        print('[InAppNotificationService] Loaded ${_dismissedIds.length} dismissed IDs');
      }
    } catch (e) {
      print('[InAppNotificationService] Gagal load dismissed IDs: $e');
    }
  }

  bool _isSaving = false;
  bool _needsSave = false;

  Future<void> _saveDismissedIds() async {
    if (_isSaving) {
      _needsSave = true;
      return;
    }
    _isSaving = true;
    _needsSave = false;
    
    try {
      final jsonStr = jsonEncode(_dismissedIds.toList());
      print('[InAppNotificationService] Saving JSON: $jsonStr');
      await _storage.write(key: 'dismissed_notifications_ids', value: jsonStr);
    } catch (e) {
      print('[InAppNotificationService] Gagal save dismissed IDs: $e');
    } finally {
      _isSaving = false;
      if (_needsSave) {
        _saveDismissedIds(); // Jalankan lagi jika ada perubahan tertunda
      }
    }
  }

  // ─── Pomodoro ─────────────────────────────────────────────────────────────

  /// Tambahkan notifikasi "Sesi Fokus Selesai" ke in-app notification list.
  /// [sessionNumber] = urutan sesi fokus yang baru saja selesai hari ini.
  void addFocusSessionCompleted({required int sessionNumber}) {
    /* 
    final notif = NotifikasiModel(
      id: 'pomodoro_focus_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Sesi Fokus Selesai! ⏰',
      body:
          'Kerja bagus! Sesi fokus Pomodoro ke-$sessionNumber Anda hari ini selesai. Waktunya beristirahat sejenak.',
      timestamp: DateTime.now(),
      isRead: false,
      category: 'productivity',
      route: Routes.MAIN,
    );
    notifications.insert(0, notif);
    */
  }

  // ─── Todo Deadline ─────────────────────────────────────────────────────────

  /// Tambahkan notifikasi deadline todo jika belum pernah ditambahkan atau di-dismiss.
  /// Dipanggil oleh NotifikasiController saat membuka halaman notifikasi.
  void addTodoDeadlineNotification({
    required String todoId,
    required String todoTitle,
    required DateTime deadline,
  }) {
    final id = 'deadline_$todoId';
    if (_addedIds.contains(id) || _dismissedIds.contains(id))
      return; // skip jika sudah ada atau pernah dihapus
    _addedIds.add(id);

    final now = DateTime.now();
    final diff = deadline.difference(now);

    String timeText;
    if (diff.isNegative) {
      timeText = 'sudah melewati deadline';
    } else if (diff.inMinutes < 60) {
      timeText = 'dalam ${diff.inMinutes} menit lagi';
    } else if (diff.inHours < 24) {
      timeText =
          'hari ini pukul ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')} WIB';
    } else {
      timeText =
          '${deadline.day}/${deadline.month}/${deadline.year} pukul ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')} WIB';
    }

    final notif = NotifikasiModel(
      id: id,
      title: 'Tugas Mendekati Deadline 📅',
      body:
          '"$todoTitle" harus diselesaikan $timeText. Klik untuk melihat daftar tugas.',
      timestamp: DateTime.now(),
      isRead: false,
      category: 'productivity',
      route: Routes.TODOLIST,
    );
    notifications.insert(0, notif);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void markAsRead(String id) {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
  }

  void remove(String id) {
    notifications.removeWhere((n) => n.id == id);
    _addedIds.remove(id);
    _dismissedIds.add(id);
    _saveDismissedIds();

    // Jika notifikasi hidrasi dihapus, batalkan juga notifikasi sistemnya
    if (id.startsWith('hydration_')) {
      final parts = id.split('_');
      if (parts.length >= 3) {
        final timePart = parts[2]; // format HHMM
        if (timePart.length == 4) {
          final hh = int.tryParse(timePart.substring(0, 2));
          final mm = int.tryParse(timePart.substring(2, 4));
          if (hh != null && mm != null) {
            final slotMins = hh * 60 + mm;
            final systemNotifId = 10000 + slotMins;
            if (Get.isRegistered<NotificationService>()) {
              Get.find<NotificationService>().flutterLocalNotificationsPlugin.cancel(id: systemNotifId);
            }
          }
        }
      }
    } else if (id.startsWith('deadline_')) {
      // Jika notifikasi todo dihapus, batalkan juga notifikasi sistemnya
      final todoId = id.replaceFirst('deadline_', '');
      if (Get.isRegistered<NotificationService>()) {
        Get.find<NotificationService>().cancelTodoDeadlineNotification(todoId);
      }
    }
  }

  void clearAll() {
    for (final notif in notifications) {
      _dismissedIds.add(notif.id);
      
      // Jika notifikasi hidrasi, batalkan juga notifikasi sistemnya
      if (notif.id.startsWith('hydration_')) {
        final parts = notif.id.split('_');
        if (parts.length >= 3) {
          final timePart = parts[2];
          if (timePart.length == 4) {
            final hh = int.tryParse(timePart.substring(0, 2));
            final mm = int.tryParse(timePart.substring(2, 4));
            if (hh != null && mm != null) {
              final slotMins = hh * 60 + mm;
              final systemNotifId = 10000 + slotMins;
              if (Get.isRegistered<NotificationService>()) {
                Get.find<NotificationService>().flutterLocalNotificationsPlugin.cancel(id: systemNotifId);
              }
            }
          }
        }
      } else if (notif.id.startsWith('deadline_')) {
        final todoId = notif.id.replaceFirst('deadline_', '');
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().cancelTodoDeadlineNotification(todoId);
        }
      }
    }
    notifications.clear();
    _addedIds.clear();
    _saveDismissedIds();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
