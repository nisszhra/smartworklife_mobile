import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(
      () => SignupController(
        Get.find<AuthRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
