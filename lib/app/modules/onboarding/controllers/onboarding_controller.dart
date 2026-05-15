import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/services/user_service.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  final PageController pageController = PageController();

  // Health Profile Fields
  var selectedGender = ''.obs; // 'Laki-laki' or 'Perempuan'
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  // Work Profile Fields
  var startTime = '08:00'.obs;
  var endTime = '17:00'.obs;
  var selectedIndustry = ''.obs;

  final List<String> industries = [
    'Teknologi',
    'Kesehatan',
    'Pendidikan',
    'Kreatif',
    'Bisnis',
    'Lainnya'
  ];

  void next() {
    if (currentPage.value == 0) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
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

  void finish() {
    print('Finishing onboarding...');
    
    // Save to UserService
    final userService = Get.put(UserService());
    userService.selectedGender.value = selectedGender.value;
    userService.age.value = ageController.text;
    userService.weight.value = weightController.text;
    userService.height.value = heightController.text;
    userService.startTime.value = startTime.value;
    userService.endTime.value = endTime.value;
    userService.selectedIndustry.value = selectedIndustry.value;

    Get.offAllNamed('/main');
  }

  @override
  void onClose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    pageController.dispose();
    super.onClose();
  }
}
