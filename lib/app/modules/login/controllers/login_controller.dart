import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthRepository _repository;
  final AuthService _authService;

  LoginController(this._repository, this._authService);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Visibility state untuk password
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan password tidak boleh kosong.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.login(email, password);
      await _authService.saveToken(response.accessToken);
      if (response.user != null) {
        print("DEBUG: User data received: ${response.user!.fullName}");
        await _authService.saveUser(response.user!);
      } else {
        print("DEBUG: No user data in login response!");
      }
      Get.offAllNamed(Routes.MAIN);
    } catch (e) {
      final err = e.toString().replaceFirst('Exception: ', '');
      if (err.contains('Email belum diverifikasi')) {
        // Jika belum verifikasi, kirim ke halaman OTP
        Get.toNamed(Routes.VERIFIKASI, arguments: {'email': email});
        Get.snackbar('Verifikasi Diperlukan', 'Email Anda belum diverifikasi. Silakan masukkan kode OTP yang telah dikirim.');
        
        // Opsional: Langsung panggil resend agar user dapat kode baru
        try { _repository.resendOtp(email); } catch (_) {}
      } else {
        errorMessage.value = err;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignup() => Get.toNamed(Routes.SIGNUP);

  void goToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);
}
