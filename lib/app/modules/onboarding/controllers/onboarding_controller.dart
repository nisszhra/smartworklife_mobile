import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';

class OnboardingController extends GetxController {
  final AuthRepository _repository;
  final _authService = Get.find<AuthService>();

  OnboardingController(this._repository);

  var currentPage = 0.obs;
  final PageController pageController = PageController();

  // Health Profile Fields
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();
  var isEditingName = false.obs;
  var selectedGender = ''.obs; // 'Laki-laki' or 'Perempuan'
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  // Work Profile Fields
  var startTime = '08:00'.obs;
  var endTime = '17:00'.obs;
  var selectedIndustry = ''.obs;
  final otherIndustryController = TextEditingController();

  final List<String> industries = [
    'Teknologi',
    'Kesehatan',
    'Pendidikan',
    'Kreatif',
    'Bisnis',
    'Lainnya'
  ];

  @override
  void onInit() {
    super.onInit();
    nameController.text = _authService.currentUser.value?.fullName ?? '';
    nameFocusNode.addListener(() {
      if (!nameFocusNode.hasFocus) {
        isEditingName.value = false;
      }
    });
  }

  void next() {
    if (currentPage.value == 0) {
      // Validasi Step 1: Profil Kesehatan
      final fullNameText = nameController.text.trim();
      final nameParts = fullNameText.split(RegExp(r'\s+'));
      if (fullNameText.isEmpty || nameParts.length < 2) {
        Get.snackbar('Data Belum Lengkap', 'Nama Lengkap harus terdiri dari minimal 2 kata.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
        return;
      }
      if (selectedGender.value.isEmpty) {
        Get.snackbar('Data Belum Lengkap', 'Silakan pilih Jenis Kelamin Anda.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
        return;
      }
      if (ageController.text.isEmpty || weightController.text.isEmpty || heightController.text.isEmpty) {
        Get.snackbar('Data Belum Lengkap', 'Silakan isi Umur, Berat Badan, dan Tinggi Badan Anda.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
        return;
      }

      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Validasi Step 2: Profil Pekerjaan
      if (selectedIndustry.value.isEmpty) {
        Get.snackbar('Data Belum Lengkap', 'Silakan pilih Bidang Industri Anda.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
        return;
      }
      if (selectedIndustry.value == 'Lainnya' && otherIndustryController.text.trim().isEmpty) {
        Get.snackbar('Data Belum Lengkap', 'Silakan isi Bidang Industri Anda.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
        return;
      }
      finish();
    }
  }

  void previous() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      startTime.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) {
      endTime.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void finish() async {
    print('Finishing onboarding and saving to DB...');
    
    try {
      // 1. Save to Backend Database
      final industryToSave = selectedIndustry.value == 'Lainnya' ? otherIndustryController.text.trim() : selectedIndustry.value;
      final updatedUser = await _repository.onboarding(
        fullName: nameController.text.isNotEmpty ? nameController.text : null,
        gender: selectedGender.value,
        age: int.tryParse(ageController.text),
        industry: industryToSave,
        startTime: startTime.value,
        endTime: endTime.value,
        weight: double.tryParse(weightController.text),
        height: double.tryParse(heightController.text),
      );

      // 2. Sync to AuthService (Global State)
      await _authService.saveUser(updatedUser);

      // 3. Save to Local UserService (Internal Sync)
      final userService = Get.put(UserService());
      userService.selectedGender.value = selectedGender.value;
      userService.age.value = ageController.text;
      userService.weight.value = weightController.text;
      userService.height.value = heightController.text;
      userService.startTime.value = startTime.value;
      userService.endTime.value = endTime.value;
      userService.selectedIndustry.value = industryToSave;

      Get.offAllNamed('/main');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan profil: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    nameFocusNode.dispose();
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    otherIndustryController.dispose();
    pageController.dispose();
    super.onClose();
  }
}
