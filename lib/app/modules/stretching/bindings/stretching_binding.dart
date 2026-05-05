import 'package:get/get.dart';

import '../controllers/stretching_controller.dart';

class StretchingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StretchingController>(
      () => StretchingController(),
    );
  }
}
