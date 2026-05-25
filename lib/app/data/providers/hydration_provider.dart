import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/services/dio_service.dart';

/// Raw HTTP calls ke endpoint /health/hydration/*.
class HydrationProvider {
  HydrationProvider();

  dio.Dio get _dio => Get.find<DioService>().client;

  /// GET /health/hydration/today
  Future<dio.Response> getTodayHydration() {
    return _dio.get('/health/hydration/today');
  }

  /// POST /health/hydration/logs — log minum (amount_ml)
  Future<dio.Response> addLog(double amountMl) {
    return _dio.post('/health/hydration/logs', data: {'amount_ml': amountMl});
  }

  /// DELETE /health/hydration/logs/{log_id}
  Future<dio.Response> deleteLog(String logId) {
    return _dio.delete('/health/hydration/logs/$logId');
  }

  /// GET /health/hydration/settings
  Future<dio.Response> getSettings() {
    return _dio.get('/health/hydration/settings');
  }

  /// GET /health/bmi
  Future<dio.Response> getBmi() {
    return _dio.get('/health/bmi');
  }
}
