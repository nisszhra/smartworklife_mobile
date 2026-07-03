import 'dart:async';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/repositories/pomodoro_repository.dart';
import '../../home/controllers/home_controller.dart';

enum PomodoroMode { klasik, deepWork, extended }

enum PomodoroState { idle, working, breaking }

class PomodoroController extends GetxController with WidgetsBindingObserver {
  // Dependencies
  final PomodoroRepository _repository;
  PomodoroController(this._repository);

  // Current mode
  final selectedMode = Rx<PomodoroMode?>(null);
  final pomodoroState = PomodoroState.idle.obs;
  final isPaused = false.obs;

  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final ReceivePort _port = ReceivePort();

  // Timer
  final remainingSeconds = 0.obs;
  final totalSeconds = 0.obs;
  Timer? _timer;
  DateTime? _lastBackgroundTime;

  // Session count
  final completedSessions = 0.obs;
  final totalTargetSessions = 4.obs;

  // Phases
  final currentPhaseIndex = 0.obs;

  // Rest Activities Checkboxes
  final hydrateChecked = false.obs;
  final refuelChecked = false.obs;
  final eyeRestChecked = false.obs;

  // ─── API tracking ──────────────────────────────────────────────────
  /// ID sesi yang sedang berjalan di backend (null = belum ada)
  String? _currentSessionId;
  /// Waktu mulai sesi ini di client (untuk hitung actual duration)
  DateTime? _sessionStartTime;

  // Mode configurations (durasi asli sesuai masing-masing mode)
  Map<PomodoroMode, List<Map<String, dynamic>>> get modeConfig => {
    PomodoroMode.klasik: [
      {'state': PomodoroState.working, 'minutes': 15},
      {'state': PomodoroState.breaking, 'minutes': 5},
      {'state': PomodoroState.working, 'minutes': 10},
    ],
    PomodoroMode.deepWork: [
      {'state': PomodoroState.working, 'minutes': 50},
      {'state': PomodoroState.breaking, 'minutes': 10},
    ],
    PomodoroMode.extended: [
      {'state': PomodoroState.working, 'minutes': 90},
      {'state': PomodoroState.breaking, 'minutes': 30},
    ],
  };

  String get formattedTime {
    final minutes = (remainingSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    if (totalSeconds.value == 0) return 0;
    return 1 - (remainingSeconds.value / totalSeconds.value);
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    IsolateNameServer.removePortNameMapping('pomodoro_port');
    IsolateNameServer.registerPortWithName(_port.sendPort, 'pomodoro_port');
    _port.listen((dynamic data) {
      if (data == 'pause_resume') togglePause();
      if (data == 'stop') stopSession();
    });

    // Bersihkan notifikasi yang nyangkut jika aplikasi sebelumnya tertutup paksa (Force Close)
    _notificationService.cancelPomodoroNotification();
    _notificationService.cancelPhaseEndNotification();
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    IsolateNameServer.removePortNameMapping('pomodoro_port');
    _port.close();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!isPaused.value && pomodoroState.value != PomodoroState.idle) {
        _timer?.cancel();
        _lastBackgroundTime = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!isPaused.value &&
          _lastBackgroundTime != null &&
          pomodoroState.value != PomodoroState.idle) {
        final elapsedSeconds =
            DateTime.now().difference(_lastBackgroundTime!).inSeconds;
        _lastBackgroundTime = null;
        _fastForwardTime(elapsedSeconds);
        if (pomodoroState.value != PomodoroState.idle) {
          _startTimer();
          _updateNotification();
        }
      }
    }
  }

  void _fastForwardTime(int secondsToAdvance) {
    while (secondsToAdvance > 0) {
      if (pomodoroState.value == PomodoroState.idle) break;
      if (secondsToAdvance >= remainingSeconds.value) {
        secondsToAdvance -= remainingSeconds.value;
        remainingSeconds.value = 0;
        
        _recordSessionEnd(status: 'completed');
        
        currentPhaseIndex.value++;
        _setupNextPhase();
        
        if (pomodoroState.value != PomodoroState.idle) {
          _recordSessionStart();
        }
      } else {
        remainingSeconds.value -= secondsToAdvance;
        secondsToAdvance = 0;
      }
    }
  }

  // ─── Session Lifecycle ─────────────────────────────────────────────

  void startSession(PomodoroMode mode, {int sessions = 1}) {
    selectedMode.value = mode;
    totalTargetSessions.value = sessions;
    completedSessions.value = 0;
    currentPhaseIndex.value = 0;
    isPaused.value = false;
    _currentSessionId = null;
    _startCurrentPhase();
  }

  void _setupNextPhase() {
    if (selectedMode.value == null) return;

    final phases = modeConfig[selectedMode.value]!;
    if (currentPhaseIndex.value >= phases.length) {
      // Satu set sesi selesai
      completedSessions.value++;
      if (completedSessions.value < totalTargetSessions.value) {
        currentPhaseIndex.value = 0;
        _setupNextPhase();
      } else {
        // Semua sesi selesai
        pomodoroState.value = PomodoroState.idle;
        selectedMode.value = null;
        
        // Hapus notifikasi karena seluruh sesi sudah beres
        _notificationService.cancelPomodoroNotification();
        _notificationService.cancelPhaseEndNotification();
        
        // Kembali ke halaman pemilihan sesi (pop timer view)
        Get.back();
      }
      return;
    }

    final phase = phases[currentPhaseIndex.value];
    pomodoroState.value = phase['state'];
    totalSeconds.value = phase['minutes'] * 60;
    remainingSeconds.value = totalSeconds.value;

    if (pomodoroState.value == PomodoroState.breaking) {
      hydrateChecked.value = false;
      refuelChecked.value = false;
      eyeRestChecked.value = false;
    }
  }

  void _startCurrentPhase() {
    _setupNextPhase();
    if (pomodoroState.value != PomodoroState.idle) {
      // Rekam sesi ke backend
      _recordSessionStart();
      _startTimer();
      _updateNotification();
    }
  }

  /// Kirim start_session ke backend dan simpan ID yang dikembalikan
  Future<void> _recordSessionStart() async {
    if (selectedMode.value == null) return;
    if (pomodoroState.value == PomodoroState.idle) return;

    final modeStr = _modeToString(selectedMode.value!);
    final typeStr = pomodoroState.value == PomodoroState.working ? 'focus' : 'break';
    final durationSecs = totalSeconds.value;

    _sessionStartTime = DateTime.now();
    final sessionId = await _repository.startSession(
      mode: modeStr,
      sessionType: typeStr,
      durationSeconds: durationSecs,
    );

    if (sessionId != null) {
      _currentSessionId = sessionId;
      print('[Pomodoro] Session started → ID: $sessionId');
    } else {
      print('[Pomodoro] Warning: Failed to record session start to backend');
    }
  }

  /// Kirim end_session ke backend dengan status & durasi aktual
  Future<void> _recordSessionEnd({required String status}) async {
    if (_currentSessionId == null) return;

    // Selalu gunakan selisih timer, bukan waktu real-time agar tidak rusak saat fast-forward
    final actualSecs = totalSeconds.value - remainingSeconds.value;

    final success = await _repository.endSession(
      sessionId: _currentSessionId!,
      status: status,
      actualDurationSeconds: actualSecs,
    );

    print('[Pomodoro] Session ended (status=$status, actual=${actualSecs}s) → success=$success');
    _currentSessionId = null;
    _sessionStartTime = null;

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchDashboardSummary();
    }
  }

  String _modeToString(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.klasik:
        return 'classic';
      case PomodoroMode.deepWork:
        return 'deep_work';
      case PomodoroMode.extended:
        return 'extend';
    }
  }

  // ─── Timer Controls ────────────────────────────────────────────────

  void _updateNotification() {
    final title = pomodoroState.value == PomodoroState.working
        ? 'Sesi Fokus Berjalan'
        : 'Waktu Istirahat';
    final body = selectedMode.value == PomodoroMode.klasik
        ? 'Pomodoro Klasik - Sesi ${completedSessions.value + 1}'
        : 'Pomodoro - Sesi ${completedSessions.value + 1}';

    _notificationService.showPomodoroNotification(
      remainingSeconds: remainingSeconds.value,
      title: title,
      body: body,
      isPaused: isPaused.value,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    isPaused.value = false;
    _schedulePhaseEndNotification();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        // Sesi ini selesai alami (completed)
        _recordSessionEnd(status: 'completed');
        currentPhaseIndex.value++;
        _startCurrentPhase();
      }
    });
  }

  void togglePause() {
    if (isPaused.value) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    isPaused.value = true;
    _lastBackgroundTime = null;
    _notificationService.cancelPhaseEndNotification();
    _updateNotification();
  }

  void resumeTimer() {
    if (remainingSeconds.value > 0) {
      _startTimer();
      _updateNotification();
    }
  }

  void resetSession() {
    _timer?.cancel();
    if (selectedMode.value != null) {
      final phases = modeConfig[selectedMode.value]!;
      if (currentPhaseIndex.value < phases.length) {
        final phase = phases[currentPhaseIndex.value];
        totalSeconds.value = phase['minutes'] * 60;
        remainingSeconds.value = totalSeconds.value;
      }
    }
    isPaused.value = false;
    _startTimer();
  }

  /// Stop/batalkan sesi yang sedang berjalan
  void stopSession() {
    _timer?.cancel();
    // Kirim cancelled ke backend
    _recordSessionEnd(status: 'cancelled');

    pomodoroState.value = PomodoroState.idle;
    selectedMode.value = null;
    remainingSeconds.value = 0;
    totalSeconds.value = 0;
    isPaused.value = false;
    _lastBackgroundTime = null;
    _notificationService.cancelPomodoroNotification();
    _notificationService.cancelPhaseEndNotification();
  }

  void _schedulePhaseEndNotification() {
    if (pomodoroState.value == PomodoroState.idle || selectedMode.value == null)
      return;

    final phases = modeConfig[selectedMode.value]!;
    final isLastPhaseInSession = currentPhaseIndex.value >= phases.length - 1;
    final isLastSession =
        completedSessions.value >= totalTargetSessions.value - 1;

    String title;
    String body;
    int? nextPhaseSeconds;

    if (isLastPhaseInSession && isLastSession) {
      title = 'Sesi Pomodoro Selesai!';
      body = 'Selamat! Anda telah menyelesaikan seluruh target sesi.';
    } else {
      PomodoroState nextState;
      if (isLastPhaseInSession) {
        nextState = phases[0]['state'];
        nextPhaseSeconds = phases[0]['minutes'] * 60;
      } else {
        nextState = phases[currentPhaseIndex.value + 1]['state'];
        nextPhaseSeconds = phases[currentPhaseIndex.value + 1]['minutes'] * 60;
      }

      if (nextState == PomodoroState.breaking) {
        title = 'Waktu Istirahat Tiba!';
        body = 'Saatnya beristirahat sejenak.';
      } else {
        title = 'Sesi Fokus Dimulai!';
        body = 'Mari kembali fokus bekerja.';
      }
    }

    _notificationService.schedulePhaseEndNotification(
      remainingSeconds: remainingSeconds.value,
      title: title,
      body: body,
      nextPhaseSeconds: nextPhaseSeconds,
    );
  }
}
