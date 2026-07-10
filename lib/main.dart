import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:worklife_mobile/app/bindings/initial_binding.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/dio_service.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';
import 'package:worklife_mobile/app/data/services/notification_service.dart';
import 'package:worklife_mobile/app/data/services/in_app_notification_service.dart';
import 'package:worklife_mobile/app/data/services/berita_service.dart';
import 'package:worklife_mobile/app/data/services/translation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();

  await Get.putAsync<DioService>(() async => DioService());
  Get.put(BeritaService());
  final authService = await Get.putAsync<AuthService>(
    () => AuthService().init(),
  );
  Get.put(UserService());
  await Get.putAsync<NotificationService>(() => NotificationService().init());

  // Register InAppNotificationService sebagai singleton global secara async
  await Get.putAsync<InAppNotificationService>(
    () => InAppNotificationService().init(),
    permanent: true,
  );

  // Initialize locale and language check
  final savedLocale = await TranslationService.getSavedLocale();
  final hasSelectedLang = await TranslationService.hasSelectedLanguage();

  // 4. Tentukan halaman awal berdasarkan sesi dan status onboarding
  String initialRoute = AppPages.INITIAL; // Default: Login

  if (authService.isLoggedIn) {
    if (authService.isOnboarded) {
      initialRoute = Routes.MAIN; // Dashboard jika sudah lengkap
    } else {
      // Jika belum onboarded, cek apakah sudah pilih bahasa
      initialRoute = hasSelectedLang ? Routes.ONBOARDING : Routes.LANGUAGE;
    }
  }

  print("DEBUG: Status Login: ${authService.isLoggedIn}");
  print("DEBUG: Status Onboarded: ${authService.isOnboarded}");
  print("DEBUG: Navigasi Awal ke: $initialRoute");

  runApp(
    GetMaterialApp(
      title: "Smart Work-Life",
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      translations: TranslationService(),
      locale: savedLocale,
      fallbackLocale: TranslationService.fallbackLocale,
    ),
  );
}
