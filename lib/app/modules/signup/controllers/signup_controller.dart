import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';

class SignupController extends GetxController {
  final AuthRepository _repository;

  SignupController(this._repository);

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

  void goToLogin() => Get.back();
}
