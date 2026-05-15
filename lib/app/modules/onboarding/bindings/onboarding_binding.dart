import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(Get.find<AuthRepository>()),
    );
  }
}
