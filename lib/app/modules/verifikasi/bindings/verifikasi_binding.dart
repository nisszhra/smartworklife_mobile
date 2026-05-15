import 'package:get/get.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/verifikasi_controller.dart';

class VerifikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifikasiController>(
      () => VerifikasiController(Get.find<AuthRepository>()),
    );
  }
}
