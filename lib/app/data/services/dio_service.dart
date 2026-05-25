import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';

class DioService extends GetxService {
  // TODO: Ganti dengan base URL production saat deploy
  // static const String _baseUrl = 'http://192.168.1.10:8000/api/v1';
  static const String _baseUrl = 'http://192.168.1.4:8000/api/v1';


  late final Dio client;

  @override
  void onInit() {
    super.onInit();
    client = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  /// Attach JWT token ke setiap request jika tersedia.
  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final authService = Get.find<AuthService>();
      final token = await authService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // AuthService belum ter-register (contoh: saat login/register), lanjut saja
    }
    handler.next(options);
  }

  /// Handle 401 → logout dan redirect ke login.
  void _onError(DioException err, ErrorInterceptorHandler handler) {
    // Debug log agar error terlihat di console
    print('[DioService] ERROR: ${err.type} | ${err.message}');
    print('[DioService] URL: ${err.requestOptions.uri}');
    print('[DioService] Response: ${err.response?.statusCode} - ${err.response?.data}');

    if (err.response?.statusCode == 401) {
      try {
        final authService = Get.find<AuthService>();
        authService.logout();
      } catch (_) {}
      Get.offAllNamed(Routes.LOGIN);
    }
    handler.next(err);
  }
}
