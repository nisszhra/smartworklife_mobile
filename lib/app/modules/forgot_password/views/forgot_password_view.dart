import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

/// Scaffold minimal — implementasi UI penuh menyusul sesuai design.
class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.kembali,
        ),
      ),
      body: Obx(() {
        if (controller.currentStep.value == ForgotPasswordStep.inputEmail) {
          return _buildEmailStep();
        }
        return _buildResetStep();
      }),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Masukkan email Anda.\nKami akan mengirimkan kode OTP.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                )
              : const SizedBox.shrink()),
          const SizedBox(height: 16),
          Obx(() => ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.sendOtp,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kirim OTP'),
              )),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Masukkan kode OTP dan password baru Anda.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Kode OTP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password Baru',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.confirmNewPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi Password Baru',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                )
              : const SizedBox.shrink()),
          const SizedBox(height: 16),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.resetPassword,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reset Password'),
              )),
        ],
      ),
    );
  }
}
