import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
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
            top: Get.mediaQuery.padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Pose Terdeteksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- Skeleton Overlay (Frame Putih) ---
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              width: Get.width * 0.7,
              height: Get.height * 0.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Garis Putus-putus Luar (Lengkungan)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.none, // Custom dashed border normally needed, but using opacity for effect
                      ),
                    ),
                    child: CustomPaint(
                      painter: DashedFramePainter(),
                      child: Container(),
                    ),
                  ),
                  // Frame Kepala
                  Positioned(
                    top: 50,
                    child: Container(
                      width: 90,
                      height: 90,
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
                  // Frame Bahu/Tubuh
                  Positioned(
                    top: 150,
                    child: Container(
                      width: 160,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Bottom Panel (Static) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: Get.width,
              padding: EdgeInsets.fromLTRB(24, 24, 24, Get.mediaQuery.padding.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)), // Static flat top or slight curve
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instruksi Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDF7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Instruksi: Putar leher perlahan',
                        style: TextStyle(
                          color: Color(0xFF5F6368),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Judul
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0056B3),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Peregangan Leher & Bahu',
                    style: TextStyle(
                      color: Color(0xFF70757A),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Durasi Sesi Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'DURASI SESI',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '04:20 s',
                        style: TextStyle(
                          color: Color(0xFF0056B3),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE8EDF7),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Buttons Row
                  Row(
                    children: [
                      // Tombol Back
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAED),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.chevron_left, color: Color(0xFF3C4043)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tombol Jeda (Utama)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Logic untuk jeda atau selesai
                          },
                          label: const Text(
                            'Selesai',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0056B3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
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

// Painter untuk membuat garis putus-putus di area preview
class DashedFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashWidth = 8;
    const dashSpace = 6;
    
    final path = Path();
    // Membuat lengkungan atas (U-shape terbalik)
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, -size.height * 0.2, size.width, size.height);

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
