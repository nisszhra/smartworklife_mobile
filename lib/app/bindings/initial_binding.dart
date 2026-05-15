import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/providers/auth_provider.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthProvider>(AuthProvider(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepositoryImpl(Get.find<AuthProvider>()),
      permanent: true,
    );
  }
}
