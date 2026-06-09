import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../../data/repositories/dashboard_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardProvider>(() => DashboardProvider());
    Get.lazyPut<DashboardRepository>(() => DashboardRepository(Get.find()));
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find()),
    );
  }
}
