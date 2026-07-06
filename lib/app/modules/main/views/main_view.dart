import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../health/views/health_view.dart';
import '../../pomodoro/views/pomodoro_view.dart';
import '../../notulen/views/notulen_view.dart';
import '../../stretching/views/stretching_view.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/in_app_notification_service.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: Obx(() {
          final authService = Get.find<AuthService>();
          final hasPassword = authService.currentUser.value?.hasPassword ?? true;
          final snoozed = authService.hasSnoozedPasswordReminder.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: Color(0xFF005AB4)),
                onPressed: () => Get.toNamed('/profile'),
              ),
              if (!hasPassword && !snoozed)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }),
        title: Obx(() => Text(
          _getTitle(controller.currentIndex.value),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF005AB4),
            letterSpacing: -0.5,
          ),
        )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
        actions: [
          Obx(() {
            // Coba dapatkan ChatController jika sudah diinisialisasi
            // Jika belum (baru buka aplikasi), Get.put akan menginisialisasinya
            // agar bisa memonitor pesan masuk secara background (karena ada timer di dalamnya)
            final chatCtrl = Get.isRegistered<ChatController>()
                ? Get.find<ChatController>()
                : Get.put(ChatController());
            
            final unreadCount = chatCtrl.totalUnreadCount;
            
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF005AB4)),
                  onPressed: () => Get.toNamed('/chat'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          Obx(() {
            final notifService = Get.find<InAppNotificationService>();
            final unreadNotifCount = notifService.unreadCount;
            
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Color(0xFF005AB4)),
                  onPressed: () => Get.toNamed('/notifikasi'),
                ),
                if (unreadNotifCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadNotifCount > 99 ? '99+' : unreadNotifCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomeView(),
          PomodoroView(),
          StretchingView(),
          HealthView(),
          NotulenView(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Pomodoro'),
          BottomNavigationBarItem(icon: Icon(Icons.accessibility_new), label: 'Stretching'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Notes'),
        ],
      )),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Smart WorkLife';
      case 1:
        return 'Smart Pomodoro';
      case 2:
        return 'Smart Stretching';
      case 3:
        return 'Smart Health';
      case 4:
        return 'Smart Notes';
      default:
        return 'Smart WorkLife';
    }
  }
}
