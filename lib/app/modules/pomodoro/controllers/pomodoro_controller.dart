import 'dart:async';
import 'package:get/get.dart';

enum PomodoroMode { klasik, deepWork, extended }

enum PomodoroState { idle, working, breaking }

class PomodoroController extends GetxController {
  // Current mode
  final selectedMode = Rx<PomodoroMode?>(null);
  final pomodoroState = PomodoroState.idle.obs;
  final isPaused = false.obs;

  // Timer
  final remainingSeconds = 0.obs;
  final totalSeconds = 0.obs;
  Timer? _timer;

  // Session count
  final completedSessions = 0.obs;
  final totalTargetSessions = 4.obs; // Default to 4 sessions

  // Rest Activities Checkboxes
  final hydrateChecked = false.obs;
  final refuelChecked = false.obs;
  final eyeRestChecked = false.obs;

  // Mode configurations
  Map<PomodoroMode, Map<String, int>> get modeConfig => {
        PomodoroMode.klasik: {'work': 25, 'break': 5},
        PomodoroMode.deepWork: {'work': 50, 'break': 10},
        PomodoroMode.extended: {'work': 90, 'break': 30},
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

  void startSession(PomodoroMode mode) {
    selectedMode.value = mode;
    pomodoroState.value = PomodoroState.working;
    isPaused.value = false;
    final workMinutes = modeConfig[mode]!['work']!;
    totalSeconds.value = workMinutes * 60;
    remainingSeconds.value = totalSeconds.value;
    _startTimer();
    
    // Navigate to the timer view
    // Note: I'll use Get.to(() => const PomodoroTimerView()) in the view or controller.
    // For now, let's keep it here if needed or just handle navigation in the view.
  }

  void _startTimer() {
    _timer?.cancel();
    isPaused.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        if (pomodoroState.value == PomodoroState.working) {
          completedSessions.value++;
          _startBreak();
        } else {
          // Break finished
          if (completedSessions.value < totalTargetSessions.value) {
            // Start next work session? 
            // Or just stay in break state until user continues?
            // The image suggests user can "Lanjut ke Peregangan" or maybe wait.
            // Let's stop for now.
            // pomodoroState.value = PomodoroState.idle;
          } else {
            pomodoroState.value = PomodoroState.idle;
            selectedMode.value = null;
          }
        }
      }
    });
  }

  void _startBreak() {
    pomodoroState.value = PomodoroState.breaking;
    isPaused.value = false;
    final breakMinutes = modeConfig[selectedMode.value]!['break']!;
    totalSeconds.value = breakMinutes * 60;
    remainingSeconds.value = totalSeconds.value;
    
    // Reset checkboxes for new break
    hydrateChecked.value = false;
    refuelChecked.value = false;
    eyeRestChecked.value = false;

    _startTimer();
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
  }

  void resumeTimer() {
    if (remainingSeconds.value > 0) {
      _startTimer();
    }
  }

  void resetSession() {
    _timer?.cancel();
    isPaused.value = false;
    if (selectedMode.value != null) {
      final isWorking = pomodoroState.value == PomodoroState.working;
      final minutes = isWorking 
          ? modeConfig[selectedMode.value!]!['work']!
          : modeConfig[selectedMode.value!]!['break']!;
      totalSeconds.value = minutes * 60;
      remainingSeconds.value = totalSeconds.value;
    }
  }

  void stopSession() {
    _timer?.cancel();
    pomodoroState.value = PomodoroState.idle;
    selectedMode.value = null;
    remainingSeconds.value = 0;
    totalSeconds.value = 0;
    isPaused.value = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

