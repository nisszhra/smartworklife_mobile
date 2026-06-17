import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/services/dio_service.dart';

/// Raw HTTP calls ke endpoint /api/v1/auth/*.
/// Tidak mengandung business logic — hanya melempar request dan return Response.
class AuthProvider {
  AuthProvider();

  dio.Dio get _dio => Get.find<DioService>().client;

  Future<dio.Response> login(String email, String password) {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<dio.Response> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _dio.post('/auth/register', data: {
      'full_name': fullName,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    });
  }

  Future<dio.Response> verifyOtp(String email, String otpCode) {
    return _dio.post('/auth/verify-otp', data: {
      'email': email,
      'otp_code': otpCode,
    });
  }

  Future<dio.Response> resendOtp(String email) {
    return _dio.post('/auth/resend-otp', data: {'email': email});
  }

  Future<dio.Response> forgotPassword(String email) {
    return _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<dio.Response> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) {
    return _dio.post('/auth/reset-password', data: {
      'email': email,
      'otp_code': otpCode,
      'new_password': newPassword,
    });
  }

  Future<dio.Response> updateProfile({
    String? fullName,
    String? gender,
    int? age,
    String? industry,
    String? startTime,
    String? endTime,
    double? weight,
    double? height,
  }) {
    return _dio.put('/auth/profile', data: {
      if (fullName != null) 'full_name': fullName,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (industry != null) 'industry': industry,
      if (startTime != null) 'work_start_time': startTime,
      if (endTime != null) 'work_end_time': endTime,
      if (weight != null) 'weight_kg': weight,
      if (height != null) 'height_cm': height,
    });
  }

  Future<dio.Response> onboarding({
    String? gender,
    int? age,
    String? industry,
    String? startTime,
    String? endTime,
    double? weight,
    double? height,
  }) {
    return _dio.put('/auth/onboarding', data: {
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (industry != null) 'industry': industry,
      if (startTime != null) 'work_start_time': startTime,
      if (endTime != null) 'work_end_time': endTime,
      if (weight != null) 'weight_kg': weight,
      if (height != null) 'height_cm': height,
    });
  }

  Future<dio.Response> googleAuth(String idToken) {
    return _dio.post('/auth/google', data: {
      'id_token': idToken,
    });
  }

  Future<dio.Response> uploadAvatar(String filePath) async {
    final filename = filePath.split('/').last;
    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(
        filePath,
        filename: filename,
      ),
    });
    return _dio.post('/auth/avatar', data: formData);
  }
}
