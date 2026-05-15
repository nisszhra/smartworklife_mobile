import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(UserService());
  
  runApp(
    GetMaterialApp(
      title: "Smart-WorkLife",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
