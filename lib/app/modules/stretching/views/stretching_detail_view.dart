import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stretching_controller.dart';

class StretchingDetailView extends GetView<StretchingController> {
  const StretchingDetailView({super.key});

  static const Color primaryBlue = Color(0xFF1A73E8);

  @override
  Widget build(BuildContext context) {
    // Menggunakan Get.arguments utility
    final String title = Get.arguments ?? 'Neck Roll';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- Kamera Preview ---
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=1000&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),

          // --- Overlay Pose Terdeteksi ---
          Positioned(
            top: Get.mediaQuery.padding.top + 20, // Menggunakan Get utility untuk padding top
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Pose Terdeteksi',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Skeleton Overlay ---
          Center(
            child: Container(
              width: Get.width * 0.65, // Menggunakan Get.width utility
              height: Get.height * 0.45, // Menggunakan Get.height utility
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(150),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Bottom Sheet Controls ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: Get.width, // Menggunakan Get.width utility
              padding: EdgeInsets.fromLTRB(24, 24, 24, Get.mediaQuery.padding.bottom + 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Instruksi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Instruksi: Putar leher perlahan',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Latihan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Peregangan Leher & Bahu',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: '3',
                                  style: TextStyle(color: primaryBlue, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '/10',
                                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'REPETISI',
                            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.3,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F3F4),
                      valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Durasi Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: primaryBlue),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DURASI',
                              style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              '04:20 s',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Lanjutkan...',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.back(), // Get utility untuk navigasi kembali
                          icon: const Icon(Icons.pause, color: Colors.white),
                          label: const Text('Jeda', style: TextStyle(color: Colors.white, fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.fast_forward, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
