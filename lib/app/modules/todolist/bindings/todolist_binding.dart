import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/providers/todo_provider.dart';
import 'package:worklife_mobile/app/data/repositories/todo_repository.dart';
import '../controllers/todolist_controller.dart';

class TodolistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodoRepository>(
      () => TodoRepositoryImpl(TodoProvider()),
    );
    Get.lazyPut<TodolistController>(
      () => TodolistController(Get.find<TodoRepository>()),
    );
  }
}
