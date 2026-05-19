import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../health/controllers/health_controller.dart';
import '../../pomodoro/controllers/pomodoro_controller.dart';
import '../../notulen/controllers/notulen_controller.dart';
import '../../todolist/controllers/todolist_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainController>(MainController(), permanent: true);
    Get.put<HomeController>(HomeController());
    Get.put<HealthController>(HealthController(Get.find<AuthRepository>()));
    Get.put<PomodoroController>(PomodoroController());
    Get.put<NotulenController>(NotulenController());
    Get.put<TodolistController>(TodolistController());
  }
}

