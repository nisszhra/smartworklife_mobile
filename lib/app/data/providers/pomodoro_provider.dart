import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/dio_service.dart';

class PomodoroProvider {
  late final Dio _dio;

  PomodoroProvider() {
    _dio = Get.find<DioService>().client;
  }

  /// Mulai sesi Pomodoro baru → POST /pomodoro/sessions/start
  Future<Response> startSession({
    required String mode,
    required String sessionType,
    required int durationSeconds,
  }) {
    return _dio.post('/pomodoro/sessions/start', data: {
      'mode': mode,
      'session_type': sessionType,
      'duration_seconds': durationSeconds,
    });
  }

  /// Akhiri sesi Pomodoro → PUT /pomodoro/sessions/{id}/end
  Future<Response> endSession({
    required String sessionId,
    required String status,
    required int actualDurationSeconds,
  }) {
    return _dio.put('/pomodoro/sessions/$sessionId/end', data: {
      'status': status,
      'actual_duration_seconds': actualDurationSeconds,
    });
  }

  /// Ambil sesi hari ini → GET /pomodoro/sessions/today
  Future<Response> getTodaySessions() {
    return _dio.get('/pomodoro/sessions/today');
  }
}
