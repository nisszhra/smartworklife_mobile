import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/services/dio_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class FCMService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<FCMService> init() async {
    // Mendaftarkan background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Menangani pesan saat aplikasi berada di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Ambil token secara asinkron tanpa menahan proses utama (splash screen)
    _messaging.getToken().then((token) {
      if (token != null) {
        print("FCM Token: $token");
        sendTokenToBackend(token);
      }
    }).catchError((e) => print("Error getting FCM token: $e"));

    // Dengarkan perubahan token
    _messaging.onTokenRefresh.listen((newToken) {
      sendTokenToBackend(newToken);
    });
    
    return this;
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted FCM permission');
    } else {
      print('User declined or has not accepted FCM permission');
    }
  }
  
  Future<void> sendTokenToBackend(String token) async {
    try {
      if (!Get.isRegistered<DioService>()) return;
      final dio = Get.find<DioService>();
      await dio.client.put('/auth/fcm-token', data: {
        'fcm_token': token
      });
      print("Berhasil mengirim FCM Token ke backend.");
    } catch (e) {
      print("Gagal mengirim FCM token ke backend: $e");
    }
  }
}
