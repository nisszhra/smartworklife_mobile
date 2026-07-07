import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:ui';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import 'package:worklife_mobile/app/modules/main/controllers/main_controller.dart';
import 'package:worklife_mobile/app/data/services/in_app_notification_service.dart';

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
  final _storage = const FlutterSecureStorage();

  Future<NotificationService> init() async {
    // Migration: Bersihkan semua "hantu" notifikasi dari versi sebelumnya
    final hasClearedOld = await _storage.read(key: 'has_cleared_old_notifications_v3');
    if (hasClearedOld != 'true') {
      await flutterLocalNotificationsPlugin.cancelAll();
      await _storage.write(key: 'has_cleared_old_notifications_v3', value: 'true');
    }

    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback jika deteksi timezone gagal
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('ic_notification');
    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: initAndroid),
      onDidReceiveNotificationResponse: (NotificationResponse d) {
        IsolateNameServer.lookupPortByName('pomodoro_port')?.send(d.actionId);
        
        if (d.notificationResponseType == NotificationResponseType.selectedNotification) {
          final payload = d.payload;
          if (payload != null) {
            if (payload.startsWith('hydration_time_')) {
              final timeStr = payload.replaceFirst('hydration_time_', '');
              try {
                final now = DateTime.now();
                final todayKey = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
                final parts = timeStr.split(':');
                if (parts.length >= 2) {
                  final hh = parts[0].padLeft(2, '0');
                  final mm = parts[1].padLeft(2, '0');
                  final inAppNotifId = 'hydration_${todayKey}_$hh$mm';
                  if (Get.isRegistered<InAppNotificationService>()) {
                    Get.find<InAppNotificationService>().remove(inAppNotifId);
                  }
                }
              } catch (e) {
                print('[NotificationService] Error removing hydration notification: $e');
              }

              try {
                if (Get.currentRoute != Routes.MAIN) {
                  Get.offAllNamed(Routes.MAIN);
                }
                if (Get.isRegistered<MainController>()) {
                  Get.find<MainController>().changePage(3); // Health
                }
              } catch (e) {
                print('[NotificationService] Error navigating to health page: $e');
              }
            } else if (payload.startsWith('todo_deadline_')) {
              try {
                if (Get.currentRoute != Routes.TODOLIST) {
                  Get.toNamed(Routes.TODOLIST);
                }
              } catch (e) {
                print('[NotificationService] Error navigating to todolist: $e');
              }
            }
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await _requestPermission();
    return this;
  }

  Future<void> _requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // ─── Hydration ────────────────────────────────────────────────────────────

  Future<void> scheduleHydrationNotifications(List<String> times, {double remainingLiters = 0.0}) async {
    // 1. Batalkan semua notifikasi hidrasi yang terjadwal sebelumnya
    await cancelAllHydrationNotifications();

    final shortfallStr = remainingLiters.toStringAsFixed(1);
    final newIds = <String>[];
    for (final timeStr in times) {
      final parts = timeStr.split(':');
      if (parts.length < 2) continue;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final slotMins = hour * 60 + minute;
      final int notifId = 10000 + slotMins;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notifId,
        title: 'Waktunya Minum Air!',
        body: 'Kamu belum minum air sejak pukul $timeStr. Sisa target hari ini: ${shortfallStr}L.',
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'hydration_channel',
            'Hydration Reminders',
            channelDescription: 'Pengingat untuk minum air',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'hydration_time_$timeStr',
      );
      newIds.add(notifId.toString());
    }

    // Simpan daftar ID yang baru dijadwalkan ke secure storage
    await _storage.write(key: 'scheduled_hydration_ids', value: jsonEncode(newIds));
  }

  Future<void> cancelAllHydrationNotifications() async {
    try {
      final jsonStr = await _storage.read(key: 'scheduled_hydration_ids');
      if (jsonStr != null) {
        final List<dynamic> ids = jsonDecode(jsonStr);
        for (final idStr in ids) {
          final id = int.tryParse(idStr);
          if (id != null) {
            await flutterLocalNotificationsPlugin.cancel(id: id);
          }
        }
      }
    } catch (e) {
      print('[NotificationService] Gagal membatalkan notifikasi hidrasi: $e');
    }
  }

  Future<void> showPomodoroNotification({
    required int remainingSeconds,
    required String title,
    required String body,
    required bool isPaused,
  }) async {
    final targetTime = DateTime.now().add(
      Duration(seconds: remainingSeconds + 1),
    );
    await flutterLocalNotificationsPlugin.show(
      id: 888,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Timer',
          channelDescription: 'Ongoing Pomodoro session timer',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: true,
          usesChronometer: !isPaused,
          chronometerCountDown: !isPaused,
          when: isPaused ? null : targetTime.millisecondsSinceEpoch,
          // timeoutAfter = tepat di remainingSeconds agar 888 mati saat 889 muncul (tidak negatif)
          timeoutAfter: isPaused ? null : remainingSeconds * 1000,
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
        ),
      ),
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
    // Kita gunakan ID 888 untuk SEMUA notifikasi Pomodoro (ongoing & alarm).
    // Ini memastikan alarm yang muncul akan otomatis menimpa notifikasi lama,
    // mencegah terjadinya notif ganda di perangkat yang mengabaikan timeoutAfter (seperti MIUI).
    
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: remainingSeconds));

    AndroidNotificationDetails androidDetails;
    if (nextPhaseSeconds != null) {
      // Fase berikutnya ada — alarm menampilkan countdown fase baru
      androidDetails = AndroidNotificationDetails(
        'pomodoro_channel',
        'Pomodoro Timer',
        channelDescription: 'Peringatan perpindahan fase Pomodoro',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        usesChronometer: true,
        chronometerCountDown: true,
        when: scheduledDate
            .add(Duration(seconds: nextPhaseSeconds))
            .millisecondsSinceEpoch,
        // Auto-cancel saat fase berikutnya selesai (jika app tidak membuka)
        timeoutAfter: (nextPhaseSeconds + 3) * 1000,
        playSound: true,
        enableVibration: true,
      );
    } else {
      // Sesi terakhir selesai — notif sederhana
      androidDetails = const AndroidNotificationDetails(
        'pomodoro_channel',
        'Pomodoro Timer',
        channelDescription: 'Sesi Pomodoro selesai',
        importance: Importance.max,
        priority: Priority.high,
        ongoing: false,
        autoCancel: true,
        showWhen: false,
        playSound: true,
        enableVibration: true,
      );
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 888,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelPhaseEndNotification() async {
    await flutterLocalNotificationsPlugin.cancel(id: 888);
  }

  // ─── Todo Deadlines ────────────────────────────────────────────────────────

  Future<void> scheduleTodoDeadlineNotification({
    required String todoId,
    required String todoTitle,
    required DateTime deadline,
  }) async {
    final now = DateTime.now();
    
    // --- 1. Jadwalkan Notifikasi 24 Jam Sebelum Deadline ---
    final scheduledTime24h = deadline.subtract(const Duration(hours: 24));
    final int notifId24h = (todoId + "_24h").hashCode & 0x7FFFFFFF;
    
    if (scheduledTime24h.isAfter(now)) {
      final scheduledTZ24h = tz.TZDateTime.from(scheduledTime24h, tz.local);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notifId24h,
        title: 'Pengingat H-1 Deadline Tugas',
        body: 'Tugas "$todoTitle" harus selesai besok!',
        scheduledDate: scheduledTZ24h,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel',
            'Todo Reminders',
            channelDescription: 'Pengingat deadline tugas',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'todo_deadline_24h_$todoId',
      );
    }

    // --- 2. Jadwalkan Notifikasi 1 Jam Sebelum Deadline ---
    var scheduledTime1h = deadline.subtract(const Duration(hours: 1));
    final int notifId1h = todoId.hashCode & 0x7FFFFFFF;

    if (scheduledTime1h.isBefore(now)) {
      if (deadline.isAfter(now)) {
        // Jika sisa waktu kurang dari 1 jam tapi belum lewat deadline, jadwalkan 1 menit dari sekarang
        scheduledTime1h = now.add(const Duration(minutes: 1));
      } else {
        // Deadline sudah lewat, jangan jadwalkan yang 1 jam (tapi hapus yang lama jika ada)
        return;
      }
    }

    final scheduledTZ1h = tz.TZDateTime.from(scheduledTime1h, tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notifId1h,
      title: 'Tugas Mendekati Deadline 📅',
      body: '"$todoTitle" harus diselesaikan segera!',
      scheduledDate: scheduledTZ1h,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Reminders',
          channelDescription: 'Pengingat deadline tugas',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'todo_deadline_$todoId',
    );
  }

  Future<void> cancelTodoDeadlineNotification(String todoId) async {
    final int notifId1h = todoId.hashCode & 0x7FFFFFFF;
    final int notifId24h = (todoId + "_24h").hashCode & 0x7FFFFFFF;
    await flutterLocalNotificationsPlugin.cancel(id: notifId1h);
    await flutterLocalNotificationsPlugin.cancel(id: notifId24h);
  }
}
