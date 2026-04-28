import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    print('Login with ${emailController.text}');
  }

  void signup() {
    print('Navigate to Sign Up');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
