import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:worklife_mobile/app/bindings/initial_binding.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/dio_service.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';
import 'package:worklife_mobile/app/data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Init DioService dulu (tidak butuh dependency lain)
  await Get.putAsync<DioService>(() async => DioService());

  // 2. Init AuthService (restore token dari secure storage)
  // 2. Init AuthService dan tunggu sampai sesi pulih
  final authService = await Get.putAsync<AuthService>(() => AuthService().init());

  // 3. Init UserService (state form onboarding — tidak berubah)
  Get.put(UserService());

  // 3.5 Init NotificationService
  await Get.putAsync<NotificationService>(() => NotificationService().init());

  // 4. Tentukan halaman awal berdasarkan sesi dan status onboarding
  String initialRoute = AppPages.INITIAL; // Default: Login
  
  if (authService.isLoggedIn) {
    if (authService.isOnboarded) {
      initialRoute = Routes.MAIN; // Dahsboard jika sudah lengkap
    } else {
      initialRoute = Routes.ONBOARDING; // Onboarding jika data masih kosong
    }
  }

  print("DEBUG: Status Login: ${authService.isLoggedIn}");
  print("DEBUG: Status Onboarded: ${authService.isOnboarded}");
  print("DEBUG: Navigasi Awal ke: $initialRoute");
  
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

