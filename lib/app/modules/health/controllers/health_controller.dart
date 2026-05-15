import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:worklife_mobile/app/data/models/user_model.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';

class HealthController extends GetxController {
  final AuthRepository _repository;
  final _authService = Get.find<AuthService>();

  HealthController(this._repository);

  // BMI Calculator
  final height = 0.0.obs;
  final weight = 0.0.obs;
  final bmiResult = 0.0.obs;
  final bmiCategory = ''.obs;

  // Hydration
  final targetLiters = 2.8.obs;
  final intakeLiters = 0.0.obs;
  final hydrationPercentage = 0.obs;

  // Hydration schedule
  final scheduleItems = <Map<String, dynamic>>[].obs;

  // Loading state
  final isUpdating = false.obs;

  // Text editing controllers for BMI modal
  late TextEditingController heightTextController;
  late TextEditingController weightTextController;

  @override
  void onInit() {
    super.onInit();
    
    // 1. Inisialisasi controller paling awal (Mencegah LateInitializationError)
    heightTextController = TextEditingController();
    weightTextController = TextEditingController();

    // 2. Initial load data
    _updateLocalData(_authService.currentUser.value);

    // 3. Pantau perubahan user secara reaktif (Worker)
    ever(_authService.currentUser, (user) {
      _updateLocalData(user);
    });
    
    _initSchedule();
  }

  @override
  void onClose() {
    // Pastikan fokus dilepas sebelum dispose untuk mencegah error "used after disposed"
    heightTextController.dispose();
    weightTextController.dispose();
    super.onClose();
  }

  void _updateLocalData(UserModel? user) {
    // Jangan lakukan update jika controller sudah ditutup
    if (isClosed) return;

    if (user != null) {
      height.value = user.heightCm ?? 170.0;
      weight.value = user.weightKg ?? 65.0;
      
      // Update text controller dengan nilai terbaru hanya jika tidak sedang fokus/diedit
      // agar tidak mengganggu pengetikan user
      if (heightTextController.text != height.value.toStringAsFixed(0)) {
        heightTextController.text = height.value.toStringAsFixed(0);
      }
      if (weightTextController.text != weight.value.toStringAsFixed(0)) {
        weightTextController.text = weight.value.toStringAsFixed(0);
      }
      
      calculateBMI();
    }
  }

  void _initSchedule() {
    scheduleItems.value = [
      {'time': '09:00', 'completed': true},
      {'time': '11:00', 'completed': true},
      {'time': '13:00', 'completed': true},
      {'time': '15:00', 'completed': false},
      {'time': '17:00', 'completed': false},
      {'time': '19:00', 'completed': false},
      {'time': '21:00', 'completed': false},
    ];
  }

  void calculateBMI() {
    if (height.value > 0 && weight.value > 0) {
      final heightM = height.value / 100;
      bmiResult.value = weight.value / (heightM * heightM);
      bmiResult.value = double.parse(bmiResult.value.toStringAsFixed(1));

      if (bmiResult.value < 18.5) {
        bmiCategory.value = 'Underweight';
      } else if (bmiResult.value < 25.0) {
        bmiCategory.value = 'Healthy Weight';
      } else if (bmiResult.value < 30.0) {
        bmiCategory.value = 'Overweight';
      } else {
        bmiCategory.value = 'Obese';
      }
    }
  }

  Future<void> updateMeasurements() async {
    if (isUpdating.value) return;

    // Gunakan nilai saat ini jika input kosong atau tidak valid
    final h = double.tryParse(heightTextController.text) ?? height.value;
    final w = double.tryParse(weightTextController.text) ?? weight.value;
    
    if (h <= 0 || w <= 0) {
      Get.snackbar('Input Tidak Valid', 'Tinggi dan berat badan harus lebih dari 0.');
      return;
    }

    isUpdating.value = true;

    try {
      // 1. Update ke Backend
      final updatedUser = await _repository.updateProfile(
        height: h,
        weight: w,
      );

      if (isClosed) return;

      // 2. Update Lokal
      height.value = h;
      weight.value = w;
      await _authService.saveUser(updatedUser);
      
      calculateBMI();
      Get.snackbar('Berhasil', 'Data kesehatan Anda telah diperbarui.');
    } catch (e) {
      if (!isClosed) {
        Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (!isClosed) {
        isUpdating.value = false;
      }
    }
  }

  void logWater(double ml) {
    intakeLiters.value += ml / 1000;
    if (intakeLiters.value > targetLiters.value) {
      intakeLiters.value = targetLiters.value;
    }
    hydrationPercentage.value =
        ((intakeLiters.value / targetLiters.value) * 100).round();

    // Mark next uncompleted schedule item as completed
    for (int i = 0; i < scheduleItems.length; i++) {
      if (!scheduleItems[i]['completed']) {
        scheduleItems[i] = {
          'time': scheduleItems[i]['time'],
          'completed': true,
        };
        scheduleItems.refresh();
        break;
      }
    }
  }

  Color getBmiCategoryColor() {
    if (bmiResult.value < 18.5) {
      return const Color(0xFF42A5F5); // sky blue
    } else if (bmiResult.value < 25.0) {
      return const Color(0xFF4CAF50); // green
    } else if (bmiResult.value < 30.0) {
      return const Color(0xFFFFA726); // orange
    } else {
      return const Color(0xFFEF5350); // red
    }
  }
}
