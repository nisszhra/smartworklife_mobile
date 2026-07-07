import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/berita_controller.dart';

class BeritaView extends GetView<BeritaController> {
  const BeritaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'all_news'.tr,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips (Kategori)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => Row(
                children: controller.categories.map((cat) {
                  final isSelected = controller.selectedCategory.value == cat;
                  return GestureDetector(
                    onTap: () => controller.selectCategory(cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1A73E8) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
            ),
          ),
          
          // List Berita
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.beritaList.isEmpty) {
                return Center(child: Text('no_news_category'.tr));
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.beritaList.length,
                itemBuilder: (context, index) {
                  final berita = controller.beritaList[index];
                  // Menampilkan waktu rilis berita (publish time) sesuai permintaan
                  String publishTime = berita.publishedDate ?? '';
                  if (publishTime.isEmpty) publishTime = 'just_now'.tr;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    (berita.keyword ?? 'TRENDING').toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF005AB4),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (berita.source == 'YouTube') ? Colors.red[50] : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: (berita.source == 'YouTube') ? Colors.red[200]! : Colors.blue[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    berita.source ?? 'Web',
                                    style: TextStyle(
                                      color: (berita.source == 'YouTube') ? Colors.red[700] : Colors.blue[700],
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              publishTime,
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                            ),
                        const SizedBox(height: 12),
                        Text(
                          berita.title ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            if (berita.link != null && berita.link!.isNotEmpty) {
                              final url = Uri.parse(berita.link!);
                              try {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                debugPrint("Could not launch $url");
                              }
                            }
                          },
                          child: Text(
                            'read_more'.tr,
                            style: TextStyle(color: Colors.blue[600], fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
