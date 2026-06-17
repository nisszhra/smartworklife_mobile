import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worklife_mobile/app/data/models/user_model.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';
import 'package:worklife_mobile/app/data/services/dio_service.dart';

class ProfileController extends GetxController {
  final AuthRepository _repository;
  final _authService = Get.find<AuthService>();

  ProfileController(this._repository);
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
  Worker? _userWorker;

  // Profile data
  final profileImageUrl = ''.obs;

  String get fullAvatarUrl {
    final path = profileImageUrl.value;
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    try {
      final dioService = Get.find<DioService>();
      final uri = Uri.parse(dioService.client.options.baseUrl);
      return '${uri.scheme}://${uri.host}:${uri.port}$path';
    } catch (_) {
      return 'http://192.168.1.8:8000$path';
    }
  }
  final fullName = ''.obs;
  final username = ''.obs;
  final email = ''.obs;
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

    fullNameController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    bioController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    ageController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
    industryController = TextEditingController();

    // 1. Initial Load
    _updateLocalData(_authService.currentUser.value);

    // 2. Pantau perubahan user secara reaktif
    _userWorker = ever(_authService.currentUser, (user) {
      _updateLocalData(user);
    });

    // Setup listeners for changes
    _setupChangeListeners();
  }

  void _updateLocalData(UserModel? user) {
    if (isClosed) return;
    if (user != null) {
      profileImageUrl.value = user.avatarUrl ?? '';
      fullName.value = user.fullName ?? '';
      email.value = user.email;
      gender.value = user.gender ?? 'Laki-laki';
      age.value = user.age?.toString() ?? '';
      weight.value = user.weightKg == null ? '' : (user.weightKg! % 1 == 0 ? user.weightKg!.toInt().toString() : user.weightKg!.toString());
      height.value = user.heightCm == null ? '' : (user.heightCm! % 1 == 0 ? user.heightCm!.toInt().toString() : user.heightCm!.toString());
      industry.value = user.industry ?? 'Teknologi';
      startTime.value = user.workStartTime ?? '08:00';
      endTime.value = user.workEndTime ?? '17:00';

      // Update controllers
      fullNameController.text = fullName.value;
      emailController.text = email.value;
      ageController.text = age.value;
      weightController.text = weight.value;
      heightController.text = height.value;
      industryController.text = industry.value;
      
      // Reset hasChanges after sync from DB
      hasChanges.value = false;
    }
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
    hasChanges.value = true;
  }

  @override
  void onClose() {
    _userWorker?.dispose();
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
    _authService.logout();
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

  void setGender(String val) {
    gender.value = val;
    _updateHasChanges();
  }

  Future<void> changeProfilePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        isSaving.value = true;
        
        // 1. Upload to backend
        final updatedUser = await _repository.uploadAvatar(image.path);
        
        // 2. Sync to AuthService
        await _authService.saveUser(updatedUser);
        
        // 3. Update local obs
        profileImageUrl.value = updatedUser.avatarUrl ?? '';
        
        isSaving.value = false;
        Get.snackbar(
          'Berhasil',
          'Foto profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      isSaving.value = false;
      Get.snackbar(
        'Gagal',
        'Gagal mengunggah foto profil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void saveProfile() async {
    isSaving.value = true;
    
    // Validasi Full Name (harus minimal 2 kata)
    final fullNameText = fullNameController.text.trim();
    final nameParts = fullNameText.split(RegExp(r'\s+'));
    if (fullNameText.isEmpty || nameParts.length < 2) {
      isSaving.value = false;
      Get.snackbar(
        'Validasi',
        'Nama Lengkap harus terdiri dari minimal 2 kata',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      // 1. Update ke Backend Database
      final updatedUser = await _repository.updateProfile(
        fullName: fullNameText,
        gender: gender.value,
        age: int.tryParse(ageController.text),
        industry: industryController.text,
        startTime: startTime.value,
        endTime: endTime.value,
        weight: double.tryParse(weightController.text),
        height: double.tryParse(heightController.text),
      );

      // 2. Sinkronkan ke AuthService (Global State)
      await _authService.saveUser(updatedUser);

      // Update Local Obs
      fullName.value = fullNameController.text;
      username.value = usernameController.text;
      phone.value = phoneController.text;
      bio.value = bioController.text;
      
      age.value = ageController.text;
      weight.value = weightController.text;
      height.value = heightController.text;
      industry.value = industryController.text;



      // 3. Sinkronkan ke UserService (Internal Sync)
      try {
        final userService = Get.find<UserService>();
        userService.age.value = age.value;
        userService.weight.value = weight.value;
        userService.height.value = height.value;
        userService.selectedGender.value = gender.value;
        userService.startTime.value = startTime.value;
        userService.endTime.value = endTime.value;
        userService.selectedIndustry.value = industry.value;
      } catch (e) {}

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
    } catch (e) {
      isSaving.value = false;
      Get.snackbar('Error', 'Gagal menyimpan profil: ${e.toString()}');
    }
  }

  void deleteAccount() {
    Get.defaultDialog(
      title: 'Hapus Akun',
      middleText: 'Apakah Anda yakin ingin menghapus akun Anda secara permanen? Tindakan ini tidak dapat dibatalkan.',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626),
      onConfirm: () async {
        Get.back(); // Close dialog
        isSaving.value = true;
        await Future.delayed(const Duration(seconds: 1)); // Simulate api call
        isSaving.value = false;
        
        Get.snackbar(
          'Akun Dihapus',
          'Akun Anda telah berhasil dihapus.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        logout();
      },
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
