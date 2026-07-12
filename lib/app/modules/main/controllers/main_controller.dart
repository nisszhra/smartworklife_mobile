import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/services/fcm_service.dart';
import 'package:worklife_mobile/app/data/services/notification_service.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Jeda sejenak agar UI HomeView bisa ter-render terlebih dahulu
    await Future.delayed(const Duration(seconds: 1));
    
    if (Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().requestPermission();
    }
    if (Get.isRegistered<FCMService>()) {
      await Get.find<FCMService>().requestPermission();
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
