import 'package:get/get.dart';

import '../controllers/notulen_controller.dart';

class NotulenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotulenController>(
      () => NotulenController(),
    );
  }
}
