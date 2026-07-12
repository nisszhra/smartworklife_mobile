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
  late TextEditingController deletePasswordController;
  late TextEditingController deleteOtpController;
  Worker? _userWorker;

  // Profile data
  final profileImageUrl = ''.obs;

  String get fullAvatarUrl {
    final path = profileImageUrl.value;
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${DioService.baseStorageUrl}$path';
  }
  final fullName = ''.obs;
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
  final showDeletePassword = false.obs;

  // Loading state
  final isSaving = false.obs;

  bool get hasPassword => _authService.currentUser.value?.hasPassword ?? true;
  bool get isSnoozed => _authService.hasSnoozedPasswordReminder.value;

  void snoozePasswordReminder() {
    _authService.snoozePasswordReminder();
  }

  @override
  void onInit() {
    super.onInit();

    fullNameController = TextEditingController();
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
    deletePasswordController = TextEditingController();
    deleteOtpController = TextEditingController();

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
      fullNameController, emailController, phoneController,
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
    deletePasswordController.dispose();
    deleteOtpController.dispose();
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
        Get.snackbar('success'.tr, 'sb_msg_42'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      isSaving.value = false;
      Get.snackbar('error'.tr, 'sb_msg_43'.tr + ' ${e.toString()}',
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
      Get.snackbar('warning'.tr, 'sb_msg_44'.tr,
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
      Get.snackbar('success'.tr, 'sb_msg_45'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      isSaving.value = false;
      Get.snackbar('error'.tr, 'sb_msg_46'.tr + ' ${e.toString()}');
    }
  }

  void deleteAccount() async {
    deletePasswordController.clear();
    showDeletePassword.value = false;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFDC2626),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                          'delete_account_title'.tr,
                          style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'delete_account_confirm_desc'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => TextField(
                  controller: deletePasswordController,
                  obscureText: !showDeletePassword.value,
                  decoration: InputDecoration(
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('confirm_password'.tr),
                    ),
                    hintText: 'enter_password_hint'.tr,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showDeletePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () => showDeletePassword.toggle(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
                    ),
                    helperText: 'google_login_helper'.tr,
                    helperStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() => ElevatedButton(
                      onPressed: isSaving.value
                          ? null
                          : () async {
                              final password = deletePasswordController.text.trim();
                              
                              try {
                                isSaving.value = true;
                                await _repository.requestDeleteAccount(
                                  password: password.isEmpty ? null : password,
                                );
                                isSaving.value = false;
                                Get.back(); // Tutup dialog password
                                _showOtpDeleteDialog(); // Tampilkan dialog OTP
                              } catch (e) {
                                isSaving.value = false;
                                Get.snackbar(
                                  'fail'.tr,
                                  e.toString().replaceAll('Exception: ', ''),
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFDC2626),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'send_otp'.tr,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showOtpDeleteDialog() {
    deleteOtpController.clear();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_outline_rounded,
                        color: Color(0xFF4F46E5),
                        size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'enter_otp_code'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'delete_otp_desc'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: deleteOtpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  fillColor: const Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                    onPressed: isSaving.value
                        ? null
                        : () async {
                            final otp = deleteOtpController.text.trim();
                            if (otp.length < 4) {
                              Get.snackbar('warning'.tr, 'sb_msg_47'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFDC2626),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }
                            
                            try {
                              isSaving.value = true;
                              await _repository.confirmDeleteAccount(otp);
                              isSaving.value = false;
                              Get.back(); // Tutup dialog OTP
                              
                              Get.snackbar(
                                'success'.tr,
                                'account_deleted_pending_desc'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF4CAF50),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 5),
                              );
                              
                              // Tunggu sebentar lalu logout
                              await Future.delayed(const Duration(seconds: 2));
                              logout();
                            } catch (e) {
                              isSaving.value = false;
                              Get.snackbar(
                                'fail'.tr,
                                e.toString().replaceAll('Exception: ', ''),
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFDC2626),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'verify_delete'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  )),
                ],
              ),
            ],
          ),
        ),
      )),
      barrierDismissible: false,
    );
  }

  void changePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (hasPassword && currentPassword.isEmpty) {
      Get.snackbar('warning'.tr, 'sb_msg_48'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (newPassword.isEmpty) {
      Get.snackbar('warning'.tr, 'sb_msg_49'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (newPassword.length < 8) {
      Get.snackbar('warning'.tr, 'sb_msg_50'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('warning'.tr, 'sb_msg_51'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isSaving.value = true;
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.snackbar(
        'success'.tr,
        hasPassword ? 'pass_changed_success'.tr : 'pass_created_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );

      if (!hasPassword) {
        // Update user state manually so the UI knows they now have a password
        final user = _authService.currentUser.value;
        if (user != null) {
          _authService.saveUser(user.copyWith(hasPassword: true));
          _authService.clearSnoozePasswordReminder();
        }
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSaving.value = false;
    }
  }

}
