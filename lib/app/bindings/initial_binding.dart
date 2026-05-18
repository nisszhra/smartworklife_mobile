import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/providers/auth_provider.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/modules/main/controllers/main_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthProvider>(AuthProvider(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepositoryImpl(Get.find<AuthProvider>()),
      permanent: true,
    );
    Get.put<MainController>(MainController(), permanent: true);
  }
}
