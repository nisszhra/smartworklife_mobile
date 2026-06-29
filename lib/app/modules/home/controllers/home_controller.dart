import 'package:get/get.dart';
import '../../../data/models/dashboard_summary_model.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/models/berita_model.dart';
import '../../../data/services/berita_service.dart';

class HomeController extends GetxController {
  final DashboardRepository _repository;

  HomeController(this._repository);

  final selectedFilter = 'Penting'.obs;
  
  final isLoading = false.obs;
  final summary = Rx<DashboardSummaryModel?>(null);
  final errorMessage = ''.obs;

  // Berita
  final beritaService = Get.find<BeritaService>();
  final listBerita = <BeritaModel>[].obs;
  final isBeritaLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardSummary();
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    isBeritaLoading.value = true;
    try {
      // Ambil sedikit berita untuk home
      final data = await beritaService.getBerita(limit: 10);
      final validData = data.where((e) => e.title != null && e.title!.trim().isNotEmpty).take(3).toList();
      listBerita.assignAll(validData);
    } catch (e) {
      print('Error fetching berita home: $e');
    } finally {
      isBeritaLoading.value = false;
    }
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
