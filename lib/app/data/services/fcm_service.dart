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
    // Meminta izin notifikasi (untuk iOS dan Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted FCM permission');
      
      // Mendaftarkan background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Menangani pesan saat aplikasi berada di foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          // Flutter local notifications is handled by NotificationService, 
          // tapi FCM defaultnya TIDAK muncul pop-up saat aplikasi di buka,
          // Kecuali kita integrasikan dengan Flutter Local Notification.
          // Tapi tidak apa-apa, sementara kita bisa rely on ChatController polling 
          // atau kita bisa panggil NotificationService di sini.
        }
      });

      // Ambil token
      String? token = await _messaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
        await sendTokenToBackend(token);
      }

      // Dengarkan perubahan token
      _messaging.onTokenRefresh.listen((newToken) {
        sendTokenToBackend(newToken);
      });
      
    } else {
      print('User declined or has not accepted permission');
    }
    return this;
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
