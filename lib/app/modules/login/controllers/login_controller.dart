import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        await _authService.saveUser(response.user!);
      }

      if (response.message != null && response.message!.isNotEmpty) {
        Get.snackbar(
          'Pemulihan Akun',
          response.message!,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

      // Beri sedikit delay sebelum pindah agar snackbar/proses async lain tenang
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          if (_authService.isOnboarded) {
            Get.offAllNamed(Routes.MAIN);
          } else {
            Get.offAllNamed(Routes.ONBOARDING);
          }
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

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Pastikan sign out dulu agar muncul pilihan akun Google (account picker)
      await googleSignIn.signOut();

      // Prompt the user to sign in
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        isLoading.value = false;
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        errorMessage.value = 'Gagal mendapatkan Token dari Google.';
        isLoading.value = false;
        return;
      }

      final response = await _repository.googleAuth(idToken, isLogin: true);
      
      await _authService.saveToken(response.accessToken);
      if (response.user != null) {
        await _authService.saveUser(response.user!);
      }

      if (response.message != null && response.message!.isNotEmpty) {
        Get.snackbar(
          'Pemulihan Akun',
          response.message!,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          if (_authService.isOnboarded) {
            Get.offAllNamed(Routes.MAIN);
          } else {
            Get.offAllNamed(Routes.ONBOARDING);
          }
        }
      });
    } catch (e) {
      if (isClosed) return;
      final err = e.toString().replaceFirst('Exception: ', '');
      if (err.contains('Akun belum terdaftar')) {
        Get.snackbar(
          'Akun Tidak Ditemukan',
          'Akun Anda belum terdaftar. Silakan Sign Up terlebih dahulu.',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        errorMessage.value = err;
      }
      isLoading.value = false;
    }
  }

  void goToSignup() => Get.toNamed(Routes.SIGNUP);

  void goToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);
}
