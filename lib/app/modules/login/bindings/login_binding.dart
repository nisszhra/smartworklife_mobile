import 'package:get/get.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/dio_service.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // DioService & AuthService sudah di-put di main.dart — tinggal lazyPut layer auth
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthProvider>()),
    );
    Get.lazyPut<LoginController>(
      () => LoginController(
        Get.find<AuthRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
