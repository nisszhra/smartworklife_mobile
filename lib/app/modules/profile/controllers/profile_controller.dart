import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';

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
  late TextEditingController industryController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;

  // Profile data
  final profileImageUrl = ''.obs;
  final fullName = 'Sarah Koenig'.obs;
  final username = 'sarahkoenig'.obs;
  final email = 'sarah.koenig@company.com'.obs;
  final phone = '+62 812 3456 7890'.obs;
  final bio = 'Product Manager at Smart-WorkLife. Passionate about productivity and team collaboration.'.obs;
  
  // Health Profile (from Onboarding)
  final gender = 'Laki-laki'.obs;
  final age = '24'.obs;
  final weight = '65'.obs;
  final height = '175'.obs;

  // Work Profile (from Onboarding)
  final startTime = '08:00'.obs;
  final endTime = '17:00'.obs;
  final industry = 'Teknologi'.obs;

  // Change tracking
  final hasChanges = false.obs;

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

    // Initialize health/work controllers
    ageController = TextEditingController(text: age.value);
    weightController = TextEditingController(text: weight.value);
    heightController = TextEditingController(text: height.value);
    industryController = TextEditingController(text: industry.value);

    // Sync from OnboardingController if it exists
    _syncFromOnboarding();

    // Setup listeners for changes
    _setupChangeListeners();
  }

  void _setupChangeListeners() {
    final controllers = [
      fullNameController, usernameController, emailController, phoneController,
      bioController, industryController, ageController, weightController, heightController,
      currentPasswordController, newPasswordController, confirmPasswordController
    ];
    
    for (var c in controllers) {
      c.addListener(() => _updateHasChanges());
    }

    ever(gender, (_) => _updateHasChanges());
    ever(startTime, (_) => _updateHasChanges());
    ever(endTime, (_) => _updateHasChanges());
  }

  void _updateHasChanges() {
    // Basic logic: if any field is not empty or different from initial
    // For simplicity, we'll just set it to true if any listener triggers
    // or we could do a deep comparison if needed.
    hasChanges.value = true;
  }

  void _syncFromOnboarding() {
    try {
      final userService = Get.find<UserService>();
      final savedGender = userService.selectedGender.value;
      if (savedGender == 'Laki-laki' || savedGender == 'Perempuan') {
        gender.value = savedGender;
      } else {
        gender.value = 'Laki-laki'; // Default fallback
      }

      age.value = userService.age.value;
      weight.value = userService.weight.value;
      height.value = userService.height.value;
      startTime.value = userService.startTime.value;
      endTime.value = userService.endTime.value;
      industry.value = userService.selectedIndustry.value;

      // Update controllers
      ageController.text = age.value;
      weightController.text = weight.value;
      heightController.text = height.value;
      industryController.text = industry.value;
    } catch (e) {
      // UserService not found or not initialized yet
    }
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
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    industryController.dispose();
    super.onClose();
  }

  void toggleCurrentPassword() =>
      showCurrentPassword.value = !showCurrentPassword.value;
  void toggleNewPassword() =>
      showNewPassword.value = !showNewPassword.value;
  void toggleConfirmPassword() =>
      showConfirmPassword.value = !showConfirmPassword.value;
  
  void logout() {
    Get.offAllNamed('/login');
  }

  Future<void> selectStartTime(BuildContext context) async {
    final parts = startTime.value.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      startTime.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    final parts = endTime.value.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      endTime.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

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
    
    // Save health/work data
    age.value = ageController.text;
    weight.value = weightController.text;
    height.value = heightController.text;
    industry.value = industryController.text;

    // Sync back to UserService
    try {
      final userService = Get.find<UserService>();
      userService.age.value = age.value;
      userService.weight.value = weight.value;
      userService.height.value = height.value;
      userService.selectedGender.value = gender.value;
      userService.startTime.value = startTime.value;
      userService.endTime.value = endTime.value;
      userService.selectedIndustry.value = industry.value;
    } catch (e) {
      // UserService not found
    }

    isSaving.value = false;
    hasChanges.value = false;
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
