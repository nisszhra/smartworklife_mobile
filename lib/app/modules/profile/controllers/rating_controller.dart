import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/rating_repository.dart';
import '../../../data/providers/rating_provider.dart';

class RatingController extends GetxController {
  late final RatingRepository _repository;
  
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var myRatings = <dynamic>[].obs;

  final features = [
    {"name": "Keseluruhan Aplikasi", "icon": Icons.apps_rounded},
    {"name": "Pomodoro", "icon": Icons.timer_rounded},
    {"name": "Smart Todo", "icon": Icons.check_circle_rounded},
    {"name": "Smart Health (Hydration)", "icon": Icons.water_drop_rounded},
    {"name": "Smart Notulen", "icon": Icons.mic_rounded},
    {"name": "Smart Stretching", "icon": Icons.self_improvement_rounded},
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize dependency manually if not in bindings
    if (!Get.isRegistered<RatingRepository>()) {
      Get.lazyPut(() => RatingProvider());
      Get.lazyPut(() => RatingRepository(Get.find<RatingProvider>()));
    }
    _repository = Get.find<RatingRepository>();
    fetchMyRatings();
  }

  Future<void> fetchMyRatings() async {
    isLoading.value = true;
    final data = await _repository.getMyRatings();
    myRatings.assignAll(data);
    isLoading.value = false;
  }

  int getRatingFor(String featureName) {
    final existing = myRatings.firstWhere(
      (r) => r['feature_name'] == featureName,
      orElse: () => null,
    );
    return existing != null ? existing['rating'] as int : 0;
  }

  Future<void> submitRating(String featureName, int rating) async {
    isSubmitting.value = true;
    final success = await _repository.submitRating(
      featureName: featureName,
      rating: rating,
    );
    isSubmitting.value = false;

    if (success) {
      Get.snackbar('success'.tr, 'sb_msg_52'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchMyRatings();
    } else {
      Get.snackbar('error'.tr, 'sb_msg_53'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
