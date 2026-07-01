import 'package:get/get.dart';

import '../controllers/pomodoro_controller.dart';
import '../../../data/providers/pomodoro_provider.dart';
import '../../../data/repositories/pomodoro_repository.dart';

class PomodoroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PomodoroProvider>(() => PomodoroProvider());
    Get.lazyPut<PomodoroRepository>(
      () => PomodoroRepository(Get.find<PomodoroProvider>()),
    );
    Get.lazyPut<PomodoroController>(
      () => PomodoroController(Get.find<PomodoroRepository>()),
    );
  }
}
