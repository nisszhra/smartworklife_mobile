import 'package:get/get.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthProvider>()),
    );
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(Get.find<AuthRepository>()),
    );
  }
}
