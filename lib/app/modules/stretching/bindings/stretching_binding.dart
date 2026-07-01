import 'package:get/get.dart';

import '../controllers/stretching_controller.dart';
import '../../../data/providers/stretching_provider.dart';
import '../../../data/repositories/stretching_repository.dart';

class StretchingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StretchingProvider>(() => StretchingProvider());
    Get.lazyPut<StretchingRepository>(
      () => StretchingRepository(Get.find<StretchingProvider>()),
    );
    Get.lazyPut<StretchingController>(
      () => StretchingController(Get.find<StretchingRepository>()),
    );
  }
}

