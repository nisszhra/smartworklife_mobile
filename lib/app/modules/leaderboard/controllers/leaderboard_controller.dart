import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/leaderboard_model.dart';

class LeaderboardController extends GetxController {
  final _dio = Get.find<DioService>();
  final authService = Get.find<AuthService>();
  
  final users = <LeaderboardModel>[].obs;
  final isLoading = true.obs;
  final selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  bool get isToday {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
           selectedDate.value.month == now.month &&
           selectedDate.value.day == now.day;
  }

  String get formattedDate {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final dayName = days[selectedDate.value.weekday - 1];
    return '$dayName, ${DateFormat('dd/MM').format(selectedDate.value)}';
  }

  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    fetchLeaderboard();
  }

  void nextDay() {
    if (!isToday) {
      selectedDate.value = selectedDate.value.add(const Duration(days: 1));
      fetchLeaderboard();
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      isLoading.value = true;
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final response = await _dio.client.get('/dashboard/leaderboard', queryParameters: {'target_date': dateStr});
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
