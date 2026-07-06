import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/providers/hydration_provider.dart';
import 'package:worklife_mobile/app/data/providers/todo_provider.dart';
import 'package:worklife_mobile/app/data/repositories/hydration_repository.dart';
import 'package:worklife_mobile/app/data/repositories/todo_repository.dart';
import '../controllers/notifikasi_controller.dart';

class NotifikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodoProvider>(() => TodoProvider());
    Get.lazyPut<TodoRepository>(
      () => TodoRepositoryImpl(Get.find<TodoProvider>()),
    );
    Get.lazyPut<HydrationProvider>(() => HydrationProvider());
    Get.lazyPut<HydrationRepository>(
      () => HydrationRepositoryImpl(Get.find<HydrationProvider>()),
    );
    Get.lazyPut<NotifikasiController>(
      () => NotifikasiController(
        Get.find<TodoRepository>(),
        Get.find<HydrationRepository>(),
      ),
    );
  }
}
