import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/dio_service.dart';

class StretchingProvider {
  late final Dio _dio;

  StretchingProvider() {
    _dio = Get.find<DioService>().client;
  }

  /// POST /stretching/sessions — mulai sesi baru
  Future<Response> startSession({required String exerciseId}) {
    return _dio.post('/stretching/sessions', data: {
      'exercise_id': exerciseId,
    });
  }

  /// PUT /stretching/sessions/{id}/complete — selesaikan sesi
  Future<Response> completeSession({
    required String sessionId,
    int? totalReps,
    int? correctReps,
    String? status,
  }) {
    return _dio.put(
      '/stretching/sessions/$sessionId/complete',
      data: {
        if (totalReps != null) 'total_reps': totalReps,
        if (correctReps != null) 'correct_reps': correctReps,
        if (status != null) 'status': status,
      },
    );
  }

  /// GET /stretching/exercises — daftar gerakan
  Future<Response> getExercises() {
    return _dio.get('/stretching/exercises');
  }
}
