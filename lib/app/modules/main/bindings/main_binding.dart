import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/providers/hydration_provider.dart';
import 'package:worklife_mobile/app/data/providers/todo_provider.dart';
import 'package:worklife_mobile/app/data/providers/dashboard_provider.dart';
import 'package:worklife_mobile/app/data/providers/pomodoro_provider.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/data/repositories/dashboard_repository.dart';
import 'package:worklife_mobile/app/data/repositories/hydration_repository.dart';
import 'package:worklife_mobile/app/data/repositories/pomodoro_repository.dart';
import 'package:worklife_mobile/app/data/repositories/todo_repository.dart';
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
    Get.put<DashboardProvider>(DashboardProvider());
    Get.put<DashboardRepository>(DashboardRepository(Get.find<DashboardProvider>()));
    Get.put<HomeController>(HomeController(Get.find<DashboardRepository>()));
    Get.put<HydrationRepository>(HydrationRepositoryImpl(HydrationProvider()));
    Get.put<HealthController>(HealthController(
      Get.find<AuthRepository>(),
      Get.find<HydrationRepository>(),
    ));
    Get.put<PomodoroProvider>(PomodoroProvider());
    Get.put<PomodoroRepository>(PomodoroRepository(Get.find<PomodoroProvider>()));
    Get.put<PomodoroController>(PomodoroController(Get.find<PomodoroRepository>()));
    Get.put<NotulenController>(NotulenController());
    Get.put<TodoRepository>(TodoRepositoryImpl(TodoProvider()));
    Get.put<TodolistController>(TodolistController(Get.find<TodoRepository>()));
  }
}

