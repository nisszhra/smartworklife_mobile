import 'package:get/get.dart';
import '../../../data/models/dashboard_summary_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

class HomeController extends GetxController {
  final DashboardRepository _repository;

  HomeController(this._repository);

  final selectedFilter = 'Penting'.obs;
  
  final isLoading = false.obs;
  final summary = Rx<DashboardSummaryModel?>(null);
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
  }

  Future<void> fetchDashboardSummary() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repository.getDashboardSummary();
      summary.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
