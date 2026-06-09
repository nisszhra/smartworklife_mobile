import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/dio_service.dart';

class DashboardProvider {
  late final Dio _dio;

  DashboardProvider() {
    _dio = Get.find<DioService>().client;
  }

  Future<Response> getDashboardSummary() {
    return _dio.get('/dashboard/summary');
  }
}
