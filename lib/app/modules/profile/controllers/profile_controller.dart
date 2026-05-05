import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Form controllers
  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController bioController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // Profile data
  final profileImageUrl = ''.obs;
  final fullName = 'Sarah Koenig'.obs;
  final username = 'sarahkoenig'.obs;
  final email = 'sarah.koenig@company.com'.obs;
  final phone = '+62 812 3456 7890'.obs;
  final bio = 'Product Manager at Smart-WorkLife. Passionate about productivity and team collaboration.'.obs;

  // Password visibility
  final showCurrentPassword = false.obs;
  final showNewPassword = false.obs;
  final showConfirmPassword = false.obs;

  // Loading state
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fullNameController = TextEditingController(text: fullName.value);
    usernameController = TextEditingController(text: username.value);
    emailController = TextEditingController(text: email.value);
    phoneController = TextEditingController(text: phone.value);
    bioController = TextEditingController(text: bio.value);
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPassword() =>
      showCurrentPassword.value = !showCurrentPassword.value;
  void toggleNewPassword() =>
      showNewPassword.value = !showNewPassword.value;
  void toggleConfirmPassword() =>
      showConfirmPassword.value = !showConfirmPassword.value;

  void changeProfilePhoto() {
    // TODO: Implement image picker
    Get.snackbar(
      'Coming Soon',
      'Fitur ganti foto profil akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF005AB4),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
    );
  }

  void saveProfile() async {
    isSaving.value = true;
    // Simulate save
    await Future.delayed(const Duration(seconds: 1));

    fullName.value = fullNameController.text;
    username.value = usernameController.text;
    phone.value = phoneController.text;
    bio.value = bioController.text;

    isSaving.value = false;
    Get.snackbar(
      'Berhasil',
      'Profil berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
    );
  }

  void changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSaving.value = false;

    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    Get.snackbar(
      'Berhasil',
      'Password berhasil diubah',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: const Color(0xFFFFFFFF),
      margin: const EdgeInsets.all(16),
    );
  }
}
