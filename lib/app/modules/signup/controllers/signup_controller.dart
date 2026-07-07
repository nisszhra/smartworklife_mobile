import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import 'package:worklife_mobile/app/data/services/translation_service.dart';

class SignupController extends GetxController {
  final AuthRepository _repository;
  final AuthService _authService;

  SignupController(this._repository, this._authService);

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Visibility state untuk password
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  Future<void> signup() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Semua field wajib diisi.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (isClosed) return;

      // Pindah ke verifikasi dan beri snackbar
      Get.snackbar(
        'Berhasil', 
        'Pendaftaran berhasil. Silakan cek email untuk kode verifikasi.',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      
      Get.toNamed(Routes.VERIFIKASI, arguments: {'email': email});
    } catch (e) {
      if (!isClosed) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
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

      final response = await _repository.googleAuth(idToken);
      
      await _authService.saveToken(response.accessToken);
      if (response.user != null) {
        await _authService.saveUser(response.user!);
      }

      Future.delayed(const Duration(milliseconds: 100), () async {
        if (!isClosed) {
          if (_authService.isOnboarded) {
            Get.offAllNamed(Routes.MAIN);
          } else {
            final hasSelected = await TranslationService.hasSelectedLanguage();
            Get.offAllNamed(hasSelected ? Routes.ONBOARDING : Routes.LANGUAGE);
          }
        }
      });
    } catch (e) {
      if (isClosed) return;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      isLoading.value = false;
    }
  }

  void goToLogin() => Get.back();
}
