import 'package:get/get.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/leaderboard_model.dart';

class LeaderboardController extends GetxController {
  final _dio = Get.find<DioService>();
  final authService = Get.find<AuthService>();
  
  final users = <LeaderboardModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      isLoading.value = true;
      final response = await _dio.client.get('/dashboard/leaderboard');
      if (response.statusCode == 200) {
        final List data = response.data;
        users.assignAll(data.map((e) => LeaderboardModel.fromJson(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat leaderboard');
    } finally {
      isLoading.value = false;
    }
  }

  LeaderboardModel? get currentUserRank {
    final myId = authService.currentUser.value?.id;
    if (myId == null) return null;
    try {
      return users.firstWhere((u) => u.userId == myId);
    } catch (_) {
      return null;
    }
  }
}
