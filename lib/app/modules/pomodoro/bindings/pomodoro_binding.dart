import 'package:get/get.dart';

import '../controllers/pomodoro_controller.dart';

class PomodoroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PomodoroController>(
      () => PomodoroController(),
    );
  }
}
