import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../health/views/health_view.dart';
import '../../pomodoro/views/pomodoro_view.dart';
import '../../notulen/views/notulen_view.dart';
import '../../stretching/views/stretching_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Color(0xFF005AB4)),
          onPressed: () => Get.toNamed('/profile'),
        ),
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
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF005AB4)),
            onPressed: () => Get.toNamed('/notifikasi'),
          ),
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
