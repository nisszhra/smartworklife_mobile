import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../controllers/stretching_controller.dart';

class StretchingDetailView extends GetView<StretchingController> {
  const StretchingDetailView({super.key});

  static const Color primaryBlue = Color(0xFF1A73E8);

  @override
  Widget build(BuildContext context) {
    final String title = Get.arguments ?? 'Neck Tilt';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- Kamera Preview ---
          Positioned.fill(
            child: Obx(() {
              if (controller.isCameraInitialized.value) {
                return AspectRatio(
                  aspectRatio: controller.cameraController!.value.aspectRatio,
                  child: CameraPreview(controller.cameraController!),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
            }),
          ),

          // --- Overlay Pose Terdeteksi ---
          Positioned(
            top: Get.mediaQuery.padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: controller.isPoseDetected.value 
                      ? Colors.green.withOpacity(0.9) 
                      : Colors.white.withOpacity(0.9),
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
                    Icon(
                      controller.isPoseDetected.value ? Icons.check_circle : Icons.error_outline, 
                      color: controller.isPoseDetected.value ? Colors.white : Colors.orange, 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.isPoseDetected.value ? 'Pose Terdeteksi' : 'Pose Belum Terdeteksi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: controller.isPoseDetected.value ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.none,
                      ),
                    ),
                    child: CustomPaint(
                      painter: DashedFramePainter(),
                      child: Container(),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
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

          // --- Bottom Panel ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: Get.width,
              padding: EdgeInsets.fromLTRB(24, 24, 24, Get.mediaQuery.padding.bottom + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instruksi / Peringatan Box
                  Obx(() => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: controller.percentage.value > 0.1 
                          ? const Color(0xFFE8F5E9) 
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.percentage.value > 0.1 ? Colors.green : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        controller.warningMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.percentage.value > 0.1 ? Colors.green[800] : Colors.orange[900],
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
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

                  // Progress & Percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_graph, size: 18, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'PRESENTASE GERAKAN',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Obx(() => Text(
                        '${(controller.percentage.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF0056B3),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: controller.percentage.value,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFE8EDF7),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        controller.percentage.value > 0.8 ? Colors.green : Colors.blue[700]!
                      ),
                    ),
                  )),
                  const SizedBox(height: 40),

                  // Buttons Row
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAED),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.arrow_back_ios, color: Color(0xFF005AB4)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0056B3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Selesai',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
