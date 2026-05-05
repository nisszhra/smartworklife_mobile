import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../health/views/health_view.dart';
import '../../pomodoro/views/pomodoro_view.dart';
import '../../notulen/views/notulen_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomeView(),
          PomodoroView(),
          Center(child: Text('Stretching')),
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
}
