import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/models/notifikasi_model.dart';
import 'package:worklife_mobile/app/modules/main/controllers/main_controller.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';

class NotifikasiController extends GetxController {
  final notifications = <NotifikasiModel>[].obs;
  final selectedCategory = 'semua'.obs; // 'semua', 'health', 'productivity'

  @override
  void onInit() {
    super.onInit();
    _loadInitialNotifications();
  }

  void _loadInitialNotifications() {
    final now = DateTime.now();
    notifications.assignAll([
      NotifikasiModel(
        id: '1',
        title: 'Pengingat Hidrasi 💧',
        body: 'Waktunya minum air! Target hidrasi harian Anda masih kurang 600ml. Yuk ambil segelas air putih hangat sekarang.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        category: 'health',
        route: Routes.MAIN, // Main page tab index 3 (Health)
      ),
      NotifikasiModel(
        id: '2',
        title: 'Yuk Lakukan Peregangan! 🏃',
        body: 'Anda telah duduk selama 2 jam tanpa jeda. Klik di sini untuk melakukan peregangan leher dan punggung agar tidak kaku.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        category: 'health',
        route: Routes.MAIN, // Main page tab index 2 (Stretching)
      ),
      NotifikasiModel(
        id: '3',
        title: 'Tugas Mendekati Deadline 📅',
        body: 'Tugas "Penyusunan Desain UI Capstone" harus diselesaikan hari ini sebelum pukul 17:00 WIB. Klik untuk melihat daftar tugas.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        isRead: false,
        category: 'productivity',
        route: Routes.TODOLIST,
      ),
      NotifikasiModel(
        id: '4',
        title: 'Notulen Rapat Selesai Diproses 📝',
        body: 'Transkripsi otomatis rapat "Sinkronisasi Mingguan" hari ini pukul 10:00 telah selesai diproses dengan akurasi 98%.',
        timestamp: now.subtract(const Duration(hours: 4)),
        isRead: true,
        category: 'productivity',
        route: Routes.MAIN, // Main page tab index 4 (Notes)
      ),
      NotifikasiModel(
        id: '5',
        title: 'Sesi Fokus Selesai! ⏰',
        body: 'Kerja bagus! Sesi fokus Pomodoro ke-4 Anda hari ini selesai. Selamat menikmati istirahat panjang selama 15 menit.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        category: 'productivity',
        route: Routes.MAIN, // Main page tab index 1 (Pomodoro)
      ),
      NotifikasiModel(
        id: '6',
        title: 'Tips Ergonomis Harian 🩺',
        body: 'Atur posisi layar komputer Anda sejajar dengan mata untuk meminimalisir ketegangan pada otot leher.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        category: 'health',
      ),
    ]);
  }

  List<NotifikasiModel> get filteredNotifications {
    if (selectedCategory.value == 'semua') {
      return notifications;
    }
    return notifications.where((n) => n.category == selectedCategory.value).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

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
    Get.snackbar(
      'Berhasil',
      'Semua notifikasi telah ditandai sebagai dibaca',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF005AB4),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  void clearAll() {
    notifications.clear();
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
        // Redirect ke tab yang sesuai
        try {
          final mainController = Get.find<MainController>();
          if (notification.title.contains('Hidrasi')) {
            mainController.changePage(3); // Health
          } else if (notification.title.contains('Peregangan')) {
            mainController.changePage(2); // Stretching
          } else if (notification.title.contains('Notulen')) {
            mainController.changePage(4); // Notes
          } else if (notification.title.contains('Fokus')) {
            mainController.changePage(1); // Pomodoro
          }
        } catch (_) {}
        Get.back(); // Kembali dari halaman notifikasi ke shell main
      } else {
        Get.toNamed(notification.route!);
      }
    }
  }
}
