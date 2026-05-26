import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:worklife_mobile/app/data/models/hydration_model.dart';
import 'package:worklife_mobile/app/data/models/user_model.dart';
import 'package:worklife_mobile/app/data/repositories/auth_repository.dart';
import 'package:worklife_mobile/app/data/repositories/hydration_repository.dart';
import 'package:worklife_mobile/app/data/services/auth_service.dart';
import 'package:worklife_mobile/app/data/services/notification_service.dart';

class HealthController extends GetxController {
  final AuthRepository _repository;
  final HydrationRepository _hydrationRepository;
  final _authService = Get.find<AuthService>();

  HealthController(this._repository, this._hydrationRepository);

  // BMI Calculator
  final height = 0.0.obs;
  final weight = 0.0.obs;
  final bmiResult = 0.0.obs;
  final bmiCategory = ''.obs;

  // Hydration — dari API
  final targetLiters = 2.0.obs;
  final intakeLiters = 0.0.obs;
  final hydrationPercentage = 0.obs;
  final hydrationLogs = <HydrationLogModel>[].obs;
  final isHydrationLoading = false.obs;
  final isLoggingWater = false.obs;
  final hydrationSettings = Rxn<HydrationSettingModel>();
  final isUpdatingSettings = false.obs;

  // Hydration schedule (UI lama)
  final scheduleItems = <Map<String, dynamic>>[].obs;

  // Loading state BMI
  final isUpdating = false.obs;

  // Text editing controllers for BMI modal
  late TextEditingController heightTextController;
  late TextEditingController weightTextController;

  @override
  void onInit() {
    super.onInit();

    // 1. Init text controllers
    heightTextController = TextEditingController();
    weightTextController = TextEditingController();

    // 2. Load data lokal dari user yang sudah login
    _updateLocalData(_authService.currentUser.value);

    // 3. Pantau perubahan user secara reaktif
    ever(_authService.currentUser, (user) {
      _updateLocalData(user);
    });

    // 4. Fetch hydration data dari backend
    fetchTodayHydration();

    // 5. Init schedule items (UI lama)
    _initSchedule();
  }

  void _initSchedule() {
    scheduleItems.value = [
      {'time': '09:00', 'completed': false},
      {'time': '11:00', 'completed': false},
      {'time': '13:00', 'completed': false},
      {'time': '15:00', 'completed': false},
      {'time': '17:00', 'completed': false},
      {'time': '19:00', 'completed': false},
      {'time': '21:00', 'completed': false},
    ];
  }

  @override
  void onClose() {
    heightTextController.dispose();
    weightTextController.dispose();
    super.onClose();
  }

  void _updateLocalData(UserModel? user) {
    if (isClosed) return;
    if (user != null) {
      height.value = user.heightCm ?? 170.0;
      weight.value = user.weightKg ?? 65.0;

      if (heightTextController.text != height.value.toStringAsFixed(0)) {
        heightTextController.text = height.value.toStringAsFixed(0);
      }
      if (weightTextController.text != weight.value.toStringAsFixed(0)) {
        weightTextController.text = weight.value.toStringAsFixed(0);
      }

      calculateBMI();
    }
  }

  // ── Fetch data hidrasi hari ini dari backend ──────────────────────────
  Future<void> fetchTodayHydration() async {
    isHydrationLoading.value = true;
    try {
      final data = await _hydrationRepository.getTodayHydration();
      final settings = await _hydrationRepository.getSettings();
      if (isClosed) return;

      targetLiters.value = double.parse(data.targetLiters.toStringAsFixed(2));
      intakeLiters.value = double.parse(data.consumedLiters.toStringAsFixed(2));
      hydrationPercentage.value = data.progressPercent.round().clamp(0, 100);
      hydrationLogs.assignAll(data.logs);
      
      hydrationSettings.value = settings;
      _generateSchedule(settings, data.logs.length);
    } catch (e) {
      // Jika backend belum ada data BMI (404), gunakan default
      print('[HealthController] hydration fetch error: $e');
      _initSchedule();
    } finally {
      if (!isClosed) isHydrationLoading.value = false;
    }
  }

  void _generateSchedule(HydrationSettingModel settings, int completedCount) {
    final startParts = settings.reminderStartTime.split(':');
    final endParts = settings.reminderEndTime.split(':');

    if (startParts.length < 2 || endParts.length < 2) {
      _initSchedule();
      return;
    }

    int startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    int endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    if (endMinutes < startMinutes) endMinutes += 24 * 60;

    final interval = settings.reminderIntervalMinutes;
    if (interval <= 0) {
      _initSchedule();
      return;
    }

    final items = <Map<String, dynamic>>[];
    for (int t = startMinutes; t <= endMinutes; t += interval) {
      int h = (t ~/ 60) % 24;
      int m = t % 60;
      final timeStr = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      items.add({
        'time': timeStr,
        'completed': false,
      });
    }

    // Mark completed items based on log count (as an approximation for UI)
    for (int i = 0; i < items.length && i < completedCount; i++) {
      items[i]['completed'] = true;
    }

    scheduleItems.value = items;

    // --- Schedule Notifications ---
    final notificationService = Get.find<NotificationService>();
    notificationService.cancelAllHydrationNotifications().then((_) {
      if (settings.reminderEnabled) {
        for (int i = 0; i < items.length; i++) {
          final timeStr = items[i]['time'];
          notificationService.scheduleHydrationNotification(i, timeStr);
        }
      }
    });
  }

  // ── Log minum air ke backend ──────────────────────────────────────────
  Future<void> logWater(double ml) async {
    if (isLoggingWater.value) return;
    isLoggingWater.value = true;

    // Optimistic UI update
    final prevIntake = intakeLiters.value;
    final prevPercent = hydrationPercentage.value;
    intakeLiters.value = (intakeLiters.value + ml / 1000)
        .clamp(0, targetLiters.value);
    hydrationPercentage.value =
        ((intakeLiters.value / targetLiters.value) * 100).round().clamp(0, 100);

    try {
      final newLog = await _hydrationRepository.addLog(ml);
      if (!isClosed) {
        hydrationLogs.insert(0, newLog);
        
        // Tandai UI scheduleItems juga (jika ada yang false)
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
    } catch (e) {
      // Rollback optimistic update
      if (!isClosed) {
        intakeLiters.value = prevIntake;
        hydrationPercentage.value = prevPercent;
        Get.snackbar(
          'Gagal',
          e.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (!isClosed) isLoggingWater.value = false;
    }
  }

  // ── Hapus log minum ──────────────────────────────────────────────────
  Future<void> deleteLog(String logId) async {
    final index = hydrationLogs.indexWhere((l) => l.id == logId);
    if (index == -1) return;

    final removed = hydrationLogs[index];

    // Optimistic remove
    hydrationLogs.removeAt(index);
    intakeLiters.value =
        (intakeLiters.value - removed.amountMl / 1000).clamp(0, double.infinity);
    hydrationPercentage.value =
        ((intakeLiters.value / targetLiters.value) * 100).round().clamp(0, 100);

    try {
      await _hydrationRepository.deleteLog(logId);
    } catch (e) {
      // Rollback
      hydrationLogs.insert(index, removed);
      intakeLiters.value += removed.amountMl / 1000;
      hydrationPercentage.value =
          ((intakeLiters.value / targetLiters.value) * 100).round().clamp(0, 100);
      Get.snackbar(
        'Gagal',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── BMI ──────────────────────────────────────────────────────────────
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

    final h = double.tryParse(heightTextController.text) ?? height.value;
    final w = double.tryParse(weightTextController.text) ?? weight.value;

    if (h <= 0 || w <= 0) {
      Get.snackbar('Input Tidak Valid', 'Tinggi dan berat badan harus lebih dari 0.');
      return;
    }

    isUpdating.value = true;

    try {
      final updatedUser = await _repository.updateProfile(height: h, weight: w);
      if (isClosed) return;

      height.value = h;
      weight.value = w;
      await _authService.saveUser(updatedUser);
      calculateBMI();

      // Refresh hydration target karena berat badan berubah
      await fetchTodayHydration();

      Get.snackbar('Berhasil', 'Data kesehatan Anda telah diperbarui.');
    } catch (e) {
      if (!isClosed) {
        Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (!isClosed) isUpdating.value = false;
    }
  }

  Color getBmiCategoryColor() {
    if (bmiResult.value < 18.5) return const Color(0xFF42A5F5);
    if (bmiResult.value < 25.0) return const Color(0xFF4CAF50);
    if (bmiResult.value < 30.0) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  Future<void> updateHydrationSettings({
    int? reminderIntervalMinutes,
    bool? reminderEnabled,
    String? reminderStartTime,
    String? reminderEndTime,
  }) async {
    if (isUpdatingSettings.value) return;
    isUpdatingSettings.value = true;
    try {
      final updated = await _hydrationRepository.updateSettings(
        reminderIntervalMinutes: reminderIntervalMinutes,
        reminderEnabled: reminderEnabled,
        reminderStartTime: reminderStartTime,
        reminderEndTime: reminderEndTime,
      );
      if (isClosed) return;
      hydrationSettings.value = updated;
      
      // Reload & regenerate schedule
      await fetchTodayHydration();
      
      Get.snackbar('Berhasil', 'Pengaturan pengingat hidrasi telah diperbarui.');
    } catch (e) {
      if (!isClosed) {
        Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (!isClosed) isUpdatingSettings.value = false;
    }
  }
}
