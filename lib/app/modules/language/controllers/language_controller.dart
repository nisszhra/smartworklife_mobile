import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LanguageController extends GetxController {
  // Tidak dipakai oleh view baru, tapi tetap dipertahankan untuk kompatibilitas binding
  Future<void> continueToApp() async {
    final bool isFromSettings = Get.arguments?['fromSettings'] ?? false;
    if (isFromSettings) {
      Get.back();
    } else {
      Get.offAllNamed(Routes.ONBOARDING);
    }
  }
}
