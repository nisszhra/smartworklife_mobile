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
import 'package:worklife_mobile/app/modules/pomodoro/controllers/pomodoro_controller.dart';
import 'package:worklife_mobile/app/modules/pomodoro/views/pomodoro_timer_view.dart';

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
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

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
            if (payload == 'pomodoro') {
              try {
                if (Get.isRegistered<MainController>()) {
                  Get.find<MainController>().changePage(1); // Pomodoro
                  
                  if (Get.isRegistered<PomodoroController>()) {
                    final pController = Get.find<PomodoroController>();
                    if (pController.pomodoroState.value != PomodoroState.idle) {
                      // Buka halaman timer jika belum terbuka
                      if (!Get.currentRoute.contains('PomodoroTimerView')) {
                        Get.to(() => const PomodoroTimerView());
                      }
                    }
                  }
                } else {
                  Get.offAllNamed(Routes.MAIN);
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (Get.isRegistered<MainController>()) {
                      Get.find<MainController>().changePage(1);
                    }
                    if (Get.isRegistered<PomodoroController>()) {
                      final pController = Get.find<PomodoroController>();
                      if (pController.pomodoroState.value != PomodoroState.idle) {
                        Get.to(() => const PomodoroTimerView());
                      }
                    }
                  });
                }
              } catch (e) {
                print('[NotificationService] Error navigating to pomodoro page: $e');
              }
            } else if (payload.startsWith('chat_new_')) {
              try {
                final parts = payload.split('_');
                if (parts.length >= 4) {
                  final friendId = parts[2];
                  final friendName = parts.sublist(3).join('_');
                  
                  if (Get.currentRoute != Routes.CHAT_DETAIL || Get.arguments?['friendId'] != friendId) {
                    Get.toNamed(Routes.CHAT_DETAIL, arguments: {
                      'friendId': friendId,
                      'friendName': friendName,
                    });
                  }
                }
              } catch (e) {
                print('[NotificationService] Error navigating to chat detail page: $e');
              }
            } else if (payload.startsWith('hydration_time_')) {
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
    return this;
  }

  Future<void> requestPermission() async {
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
        body: 'Sudah pukul $timeStr. Jangan lupa minum air agar tidak dehidrasi! Sisa target hari ini: ${shortfallStr}L.',
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
      payload: 'pomodoro',
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

  Future<void> showChatNotification({
    required String friendId,
    required String friendName,
    required String message,
  }) async {
    // Gunakan hash ID agar notif dari orang yang sama menimpa yang lama
    final notifId = friendId.hashCode;
    
    await flutterLocalNotificationsPlugin.show(
      id: notifId,
      title: '$friendName',
      body: message,
      payload: 'chat_new_${friendId}_$friendName',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          channelDescription: 'Pemberitahuan pesan obrolan baru',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  Future<void> schedulePhaseEndNotification({
    required int remainingSeconds,
    required String title,
    required String body,
    int? nextPhaseSeconds,
  }) async {
    // Gunakan ID 889 untuk alarm perpindahan fase, terpisah dari ongoing timer (888).
    // Hal ini mencegah race condition di mana alarm menimpa notifikasi ongoing.
    
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
      id: 889,
      title: title,
      body: body,
      payload: 'pomodoro',
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelPhaseEndNotification() async {
    await flutterLocalNotificationsPlugin.cancel(id: 889);
  }

  // ─── Todo Deadlines ────────────────────────────────────────────────────────

  Future<void> scheduleTodoDeadlineNotification({
    required String todoId,
    required String todoTitle,
    required DateTime deadline,
  }) async {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative || difference.inSeconds == 0) return;

    if (difference.inHours >= 24) {
      // Lebih dari 1 hari: H-24 jam dan H-1 jam
      final scheduledTime24h = deadline.subtract(const Duration(hours: 24));
      _scheduleExactNotification(
        id: (todoId + "_first").hashCode & 0x7FFFFFFF,
        title: 'Pengingat H-1 Deadline Tugas',
        body: 'Tugas "$todoTitle" harus selesai besok!',
        scheduledTime: scheduledTime24h,
        payload: 'todo_deadline_24h_$todoId',
      );

      final scheduledTime1h = deadline.subtract(const Duration(hours: 1));
      _scheduleExactNotification(
        id: (todoId + "_second").hashCode & 0x7FFFFFFF,
        title: 'Tugas Mendekati Deadline 📅',
        body: '"$todoTitle" harus diselesaikan 1 jam lagi!',
        scheduledTime: scheduledTime1h,
        payload: 'todo_deadline_$todoId',
      );
    } else {
      // Kurang dari 1 hari
      if (difference.inHours >= 1) {
        // Setengah waktu
        final halfSeconds = difference.inSeconds ~/ 2;
        final scheduledTimeHalf = now.add(Duration(seconds: halfSeconds));
        _scheduleExactNotification(
          id: (todoId + "_first").hashCode & 0x7FFFFFFF,
          title: 'Pengingat Tugas 📅',
          body: 'Jangan lupa, tugas "$todoTitle" harus selesai hari ini!',
          scheduledTime: scheduledTimeHalf,
          payload: 'todo_deadline_half_$todoId',
        );

        // H-1 jam
        final scheduledTime1h = deadline.subtract(const Duration(hours: 1));
        _scheduleExactNotification(
          id: (todoId + "_second").hashCode & 0x7FFFFFFF,
          title: 'Tugas Mendekati Deadline 📅',
          body: '"$todoTitle" harus diselesaikan 1 jam lagi!',
          scheduledTime: scheduledTime1h,
          payload: 'todo_deadline_$todoId',
        );
      } else {
        // Kurang dari 1 jam: Setengah waktu saja
        final halfSeconds = difference.inSeconds ~/ 2;
        final scheduledTimeHalf = now.add(Duration(seconds: halfSeconds));
        _scheduleExactNotification(
          id: (todoId + "_first").hashCode & 0x7FFFFFFF,
          title: 'Tugas Mendekati Deadline 📅',
          body: '"$todoTitle" harus diselesaikan sebentar lagi!',
          scheduledTime: scheduledTimeHalf,
          payload: 'todo_deadline_$todoId',
        );
      }
    }
  }

  Future<void> _scheduleExactNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return; // Jangan jadwalkan jika waktu sudah lewat

    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTZ,
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
      payload: payload,
    );
  }

  Future<void> cancelTodoDeadlineNotification(String todoId) async {
    // Batalkan ID format lama (jika masih ada)
    final int notifId1h = todoId.hashCode & 0x7FFFFFFF;
    final int notifId24h = (todoId + "_24h").hashCode & 0x7FFFFFFF;
    await flutterLocalNotificationsPlugin.cancel(id: notifId1h);
    await flutterLocalNotificationsPlugin.cancel(id: notifId24h);

    // Batalkan ID format baru
    final int notifIdFirst = (todoId + "_first").hashCode & 0x7FFFFFFF;
    final int notifIdSecond = (todoId + "_second").hashCode & 0x7FFFFFFF;
    await flutterLocalNotificationsPlugin.cancel(id: notifIdFirst);
    await flutterLocalNotificationsPlugin.cancel(id: notifIdSecond);
  }
}
