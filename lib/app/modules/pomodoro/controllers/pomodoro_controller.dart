import 'dart:async';
import 'package:get/get.dart';

enum PomodoroMode { klasik, deepWork, extended }

enum PomodoroState { idle, working, breaking }

class PomodoroController extends GetxController {
  // Current mode
  final selectedMode = Rx<PomodoroMode?>(null);
  final pomodoroState = PomodoroState.idle.obs;

  // Timer
  final remainingSeconds = 0.obs;
  final totalSeconds = 0.obs;
  Timer? _timer;

  // Session count
  final completedSessions = 0.obs;

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
    final workMinutes = modeConfig[mode]!['work']!;
    totalSeconds.value = workMinutes * 60;
    remainingSeconds.value = totalSeconds.value;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        if (pomodoroState.value == PomodoroState.working) {
          completedSessions.value++;
          _startBreak();
        } else {
          pomodoroState.value = PomodoroState.idle;
          selectedMode.value = null;
        }
      }
    });
  }

  void _startBreak() {
    pomodoroState.value = PomodoroState.breaking;
    final breakMinutes = modeConfig[selectedMode.value]!['break']!;
    totalSeconds.value = breakMinutes * 60;
    remainingSeconds.value = totalSeconds.value;
    _startTimer();
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resumeTimer() {
    if (remainingSeconds.value > 0) {
      _startTimer();
    }
  }

  void stopSession() {
    _timer?.cancel();
    pomodoroState.value = PomodoroState.idle;
    selectedMode.value = null;
    remainingSeconds.value = 0;
    totalSeconds.value = 0;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
