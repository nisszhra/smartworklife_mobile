import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:ui';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  final send = IsolateNameServer.lookupPortByName('pomodoro_port');
  if (send != null) {
    send.send(notificationResponse.actionId);
  }
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    // Inisialisasi timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        final send = IsolateNameServer.lookupPortByName('pomodoro_port');
        if (send != null) {
          send.send(details.actionId);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    
    await _requestPermission();
    return this;
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> scheduleHydrationNotification(int id, String timeStr) async {
    final timeParts = timeStr.split(':');
    if (timeParts.length < 2) return;
    
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hydration_channel',
      'Hydration Reminders',
      channelDescription: 'Pengingat untuk minum air',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: 'Waktunya Minum Air!',
      body: 'Jangan lupa minum air agar tetap terhidrasi.',
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllHydrationNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showPomodoroNotification({
    required int remainingSeconds,
    required String title,
    required String body,
    required bool isPaused,
  }) async {
    final now = DateTime.now();
    final targetTime = now.add(Duration(seconds: remainingSeconds));
    
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Ongoing Pomodoro session timer',
      importance: Importance.low, // low so it doesn't pop up and annoy every time
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      usesChronometer: !isPaused,
      chronometerCountDown: !isPaused,
      when: isPaused ? null : targetTime.millisecondsSinceEpoch,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'pause_resume',
          isPaused ? 'Resume' : 'Pause',
          showsUserInterface: false,
          cancelNotification: false,
        ),
        const AndroidNotificationAction(
          'stop',
          'Stop',
          showsUserInterface: false,
          cancelNotification: false,
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id: 888, // Unique ID for Pomodoro
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> cancelPomodoroNotification() async {
    await flutterLocalNotificationsPlugin.cancel(id: 888);
  }

  Future<void> schedulePhaseEndNotification({
    required int remainingSeconds,
    required String title,
    required String body,
    int? nextPhaseSeconds,
  }) async {
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: remainingSeconds));
    
    AndroidNotificationDetails androidPlatformChannelSpecifics;
    
    if (nextPhaseSeconds != null) {
      final targetTimeForChronometer = scheduledDate.add(Duration(seconds: nextPhaseSeconds));
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'pomodoro_channel',
        'Pomodoro Timer',
        channelDescription: 'Ongoing Pomodoro session timer',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        usesChronometer: true,
        chronometerCountDown: true,
        when: targetTimeForChronometer.millisecondsSinceEpoch,
        playSound: true,
        enableVibration: true,
      );
    } else {
      androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'pomodoro_alert_channel',
        'Pomodoro Alerts',
        channelDescription: 'Peringatan perpindahan fase Pomodoro',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
    }
    
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 888, // Menggunakan ID yang SAMA dengan PomodoroTimer agar menimpa hitung mundur yang jadi minus
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelPhaseEndNotification() async {
    // Karena sekarang id-nya gabung dengan 888, ini bisa dibiarkan kosong
    // atau memanggil cancel(888) (tapi nanti akan dimatikan lewat cancelPomodoroNotification)
  }
}
