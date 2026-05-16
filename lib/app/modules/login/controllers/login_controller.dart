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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

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
        await _authService.saveUser(response.user!);
      }

      // Beri sedikit delay sebelum pindah agar snackbar/proses async lain tenang
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          Get.offAllNamed(Routes.MAIN);
        }
      });
    } catch (e) {
      if (isClosed) return;

      final err = e.toString().replaceFirst('Exception: ', '');
      if (err.contains('Email belum diverifikasi')) {
        Get.toNamed(Routes.VERIFIKASI, arguments: {'email': email});
        Get.snackbar(
          'Verifikasi Diperlukan', 
          'Email Anda belum diverifikasi.',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        
        try { _repository.resendOtp(email); } catch (_) {}
      } else {
        errorMessage.value = err;
      }
      isLoading.value = false;
    }
  }

  void goToSignup() => Get.toNamed(Routes.SIGNUP);

  void goToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);
}
