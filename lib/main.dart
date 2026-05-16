import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:worklife_mobile/app/bindings/initial_binding.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/dio_service.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init DioService dulu (tidak butuh dependency lain)
  await Get.putAsync<DioService>(() async => DioService());

  // 2. Init AuthService (restore token dari secure storage)
  final authService = await Get.putAsync<AuthService>(() async => AuthService());

  // 3. Init UserService (state form onboarding — tidak berubah)
  Get.put(UserService());

  // 4. Tentukan halaman awal berdasarkan sesi yang ada
  final initialRoute = authService.isLoggedIn ? Routes.MAIN : AppPages.INITIAL;

  runApp(
    GetMaterialApp(
      title: "Smart-WorkLife",
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}

