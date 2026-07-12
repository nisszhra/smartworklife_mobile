import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/translation_service.dart';

class VerifikasiController extends GetxController {
  final AuthRepository _repository;
  final _authService = Get.find<AuthService>();

  VerifikasiController(this._repository);

  final List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Timer properties
  final timerSeconds = 60.obs;
  Timer? _timer;
  final canResend = false.obs;

  String get _email => (Get.arguments as Map<String, dynamic>?)?['email'] ?? '';

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  void startTimer() {
    canResend.value = false;
    timerSeconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Pastikan controller belum ditutup sebelum update UI
      if (isClosed) {
        timer.cancel();
        return;
      }

      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        canResend.value = true;
        errorMessage.value = 'Kode OTP telah kadaluarsa. Silakan kirim ulang.';
        timer.cancel();
      }
    });
  }

  void onOtpChanged(String value, int index) {
    if (value.length == 1 && index < otpControllers.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> verifikasi() async {
    if (timerSeconds.value == 0) {
      errorMessage.value = 'OTP kadaluarsa. Klik kirim ulang.';
      return;
    }

    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      errorMessage.value = 'Masukkan kode OTP 4 digit.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.verifyOtp(_email, otp);
      
      await _authService.saveToken(response.accessToken);
      if (response.user != null) {
        await _authService.saveUser(response.user!);
      }

      // Beri snackbar dulu baru pindah agar transisi lebih aman
      Get.snackbar('success'.tr, 'sb_msg_55'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // Beri sedikit delay agar snackbar sempat muncul dan UI tidak kaget saat dispose
      Future.delayed(const Duration(milliseconds: 800), () async {
        if (!isClosed) {
          final hasSelected = await TranslationService.hasSelectedLanguage();
          Get.offAllNamed(hasSelected ? Routes.ONBOARDING : Routes.LANGUAGE);
        }
      });
    } catch (e) {
      if (!isClosed) {
        // Jika error karena masalah koneksi/dio, tampilkan pesan yang user-friendly
        final err = e.toString().replaceFirst('Exception: ', '');
        errorMessage.value = err;
        isLoading.value = false;
      }
    }
  }

  Future<void> kirimUlang() async {
    if (_email.isEmpty || !canResend.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _repository.resendOtp(_email);
      if (isClosed) return;
      
      Get.snackbar('info'.tr, 'sb_msg_56'.tr);
      startTimer(); // Reset timer
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

  void kembali() => Get.back();
}
