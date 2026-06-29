import 'package:get/get.dart';
import '../../../data/models/berita_model.dart';
import '../../../data/services/berita_service.dart';

class BeritaController extends GetxController {
  final _service = Get.find<BeritaService>();
  
  final isLoading = false.obs;
  final beritaList = <BeritaModel>[].obs;
  
  // Kategori sesuai list keyword scraping Anda
  final categories = [
    'Terkini', 'Populer', 'Politik', 'Ekonomi', 'Pemerintah',
    'Teknologi', 'Viral', 'Hiburan', 'Wisata', 'Pendidikan',
    'Pekerjaan', 'Gaji', 'Produktif', 'Hobi', 'Kuliner'
  ].obs;
  final selectedCategory = 'Terkini'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBerita();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    fetchBerita();
  }

  Future<void> fetchBerita() async {
    isLoading.value = true;
    try {
      final keyword = selectedCategory.value == 'Terkini' ? '' : selectedCategory.value.toLowerCase();
      if (keyword.isEmpty) {
        final data = await _service.getBerita(limit: 50);
        final validData = data.where((e) => e.title != null && e.title!.trim().isNotEmpty).toList();
        beritaList.assignAll(validData);
      } else {
        final data = await _service.searchBerita(keyword, limit: 50);
        final validData = data.where((e) => e.title != null && e.title!.trim().isNotEmpty).toList();
        beritaList.assignAll(validData);
      }
    } catch (e) {
      print('Error fetching berita: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
