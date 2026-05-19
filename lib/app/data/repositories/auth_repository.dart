import 'package:dio/dio.dart';

import 'package:worklife_mobile/app/data/models/auth_response_model.dart';
import 'package:worklife_mobile/app/data/models/user_model.dart';
import 'package:worklife_mobile/app/data/providers/auth_provider.dart';

/// Kontrak abstrak AuthRepository.
/// Controller bergantung pada abstraksi ini, bukan implementasi konkret.
abstract class AuthRepository {
  Future<AuthResponseModel> login(String email, String password);

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<AuthResponseModel> verifyOtp(String email, String otpCode);
  Future<void> resendOtp(String email);
  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  });

  Future<UserModel> updateProfile({
    String? gender,
    int? age,
    String? industry,
    String? startTime,
    String? endTime,
    double? weight,
    double? height,
  });
}

/// Implementasi konkret AuthRepository menggunakan AuthProvider (Dio).
class AuthRepositoryImpl implements AuthRepository {
  final AuthProvider _provider;

  AuthRepositoryImpl(this._provider);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final res = await _provider.login(email, password);
      return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await _provider.register(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp(String email, String otpCode) async {
    try {
      final res = await _provider.verifyOtp(email, otpCode);
      return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> resendOtp(String email) async {
    try {
      await _provider.resendOtp(email);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _provider.forgotPassword(email);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await _provider.resetPassword(
        email: email,
        otpCode: otpCode,
        newPassword: newPassword,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? gender,
    int? age,
    String? industry,
    String? startTime,
    String? endTime,
    double? weight,
    double? height,
  }) async {
    try {
      final res = await _provider.updateProfile(
        gender: gender,
        age: age,
        industry: industry,
        startTime: startTime,
        endTime: endTime,
        weight: weight,
        height: height,
      );
      print("DEBUG: updateProfile response data: ${res.data}");
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print("DEBUG: updateProfile DioException: ${e.message}, response: ${e.response?.data}");
      throw _handleError(e);
    } catch (e, stackTrace) {
      print("DEBUG: updateProfile Unexpected Error: $e");
      print("DEBUG: StackTrace: $stackTrace");
      throw Exception('Format data response tidak valid: $e');
    }
  }

  /// Ekstrak pesan error dari response backend (field 'detail').
  Exception _handleError(DioException e) {
    final data = e.response?.data;
    String message = 'Terjadi kesalahan. Silakan coba lagi.';
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      message = data['detail'].toString();
    }
    return Exception(message);
  }
}
