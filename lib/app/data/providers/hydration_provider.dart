import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/services/dio_service.dart';

/// Raw HTTP calls ke endpoint /health/hydration/*.
class HydrationProvider {
  HydrationProvider();

  dio.Dio get _dio => Get.find<DioService>().client;

  /// GET /health/hydration/today
  Future<dio.Response> getTodayHydration(String targetDate) {
    return _dio.get('/health/hydration/today', queryParameters: {'target_date': targetDate});
  }

  /// POST /health/hydration/logs — log minum (amount_ml)
  Future<dio.Response> addLog(double amountMl, String targetDate) {
    return _dio.post(
      '/health/hydration/logs', 
      data: {'amount_ml': amountMl},
      queryParameters: {'target_date': targetDate},
    );
  }

  /// DELETE /health/hydration/logs/{log_id}
  Future<dio.Response> deleteLog(String logId) {
    return _dio.delete('/health/hydration/logs/$logId');
  }

  /// GET /health/hydration/settings
  Future<dio.Response> getSettings() {
    return _dio.get('/health/hydration/settings');
  }

  /// PUT /health/hydration/settings
  Future<dio.Response> updateSettings({
    int? reminderIntervalMinutes,
    bool? reminderEnabled,
    String? reminderStartTime,
    String? reminderEndTime,
  }) {
    final data = <String, dynamic>{};
    if (reminderIntervalMinutes != null) {
      data['reminder_interval_minutes'] = reminderIntervalMinutes;
    }
    if (reminderEnabled != null) {
      data['reminder_enabled'] = reminderEnabled;
    }
    if (reminderStartTime != null) {
      data['reminder_start_time'] = reminderStartTime;
    }
    if (reminderEndTime != null) {
      data['reminder_end_time'] = reminderEndTime;
    }
    return _dio.put('/health/hydration/settings', data: data);
  }

  /// GET /health/bmi
  Future<dio.Response> getBmi() {
    return _dio.get('/health/bmi');
  }
}

