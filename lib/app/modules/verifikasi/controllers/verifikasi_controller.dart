import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifikasiController extends GetxController {
  final List<TextEditingController> otpControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  void onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  void verifikasi() {
    String otp = otpControllers.map((c) => c.text).join();
    print('Verifying OTP: $otp');
    // Navigate to onboarding page
    Get.offAllNamed('/onboarding');
  }

  void kirimUlang() {
    print('Sending OTP again...');
  }

  void kembali() {
    Get.back();
  }
}
