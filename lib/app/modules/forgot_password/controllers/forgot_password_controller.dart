import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

/// Mode layar: input email atau reset password setelah OTP diterima.
enum ForgotPasswordStep { inputEmail, resetPassword }

class ForgotPasswordController extends GetxController {
  final AuthRepository _repository;

  ForgotPasswordController(this._repository);

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentStep = ForgotPasswordStep.inputEmail.obs;

  // Visibility state untuk password
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  /// Step 1 — kirim OTP ke email
  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errorMessage.value = 'err_email_empty'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _repository.forgotPassword(email);
      currentStep.value = ForgotPasswordStep.resetPassword;
      Get.snackbar('info'.tr, 'otp_sent_info'.tr);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2 — reset password dengan OTP yang diterima
  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmNewPasswordController.text;

    if (newPassword != confirmPassword) {
      errorMessage.value = 'err_pass_not_match'.tr;
      return;
    }
    if (newPassword.length < 8) {
      errorMessage.value = 'err_pass_length'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _repository.resetPassword(
        email: emailController.text.trim(),
        otpCode: otpController.text.trim(),
        newPassword: newPassword,
      );
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar('success'.tr, 'pass_reset_success'.tr);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void kembali() => Get.back();

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}
