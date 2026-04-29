import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HealthController extends GetxController {
  // BMI Calculator
  final height = 178.0.obs;
  final weight = 71.0.obs;
  final bmiResult = 0.0.obs;
  final bmiCategory = ''.obs;

  // Hydration
  final targetLiters = 2.8.obs;
  final intakeLiters = 0.0.obs;
  final hydrationPercentage = 0.obs;

  // Hydration schedule
  final scheduleItems = <Map<String, dynamic>>[].obs;

  // Text editing controllers for BMI modal
  late TextEditingController heightTextController;
  late TextEditingController weightTextController;

  @override
  void onInit() {
    super.onInit();
    heightTextController = TextEditingController(text: height.value.toStringAsFixed(0));
    weightTextController = TextEditingController(text: weight.value.toStringAsFixed(0));
    calculateBMI();
    _initSchedule();
  }

  @override
  void onClose() {
    heightTextController.dispose();
    weightTextController.dispose();
    super.onClose();
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

  void updateMeasurements() {
    final h = double.tryParse(heightTextController.text);
    final w = double.tryParse(weightTextController.text);
    if (h != null && h > 0) height.value = h;
    if (w != null && w > 0) weight.value = w;
    calculateBMI();
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
