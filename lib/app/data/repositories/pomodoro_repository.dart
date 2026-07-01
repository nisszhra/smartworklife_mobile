import '../providers/pomodoro_provider.dart';

class PomodoroRepository {
  final PomodoroProvider _provider;

  PomodoroRepository(this._provider);

  /// Mulai sesi baru di backend, kembalikan session_id
  Future<String?> startSession({
    required String mode,
    required String sessionType,
    required int durationSeconds,
  }) async {
    try {
      final response = await _provider.startSession(
        mode: mode,
        sessionType: sessionType,
        durationSeconds: durationSeconds,
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data['id'] as String?;
      }
    } catch (e) {
      print('[PomodoroRepo] startSession error: $e');
    }
    return null;
  }

  /// Akhiri sesi di backend dengan status dan durasi aktual
  Future<bool> endSession({
    required String sessionId,
    required String status,
    required int actualDurationSeconds,
  }) async {
    try {
      final response = await _provider.endSession(
        sessionId: sessionId,
        status: status,
        actualDurationSeconds: actualDurationSeconds,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[PomodoroRepo] endSession error: $e');
      return false;
    }
  }
}
