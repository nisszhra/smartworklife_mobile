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
                return ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: Get.width,
                      height: Get.width * controller.cameraController!.value.aspectRatio,
                      child: CameraPreview(controller.cameraController!),
                    ),
                  ),
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

          // --- Bottom Panel ---
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(24, 24, 24, Get.mediaQuery.padding.bottom + 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.55), // Transparan saja
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Instruksi / Peringatan Box (Real-time feedback)
                      Obx(() => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: controller.isPoseDetected.value 
                              ? const Color(0xFFE8F5E9).withOpacity(0.85) 
                              : const Color(0xFFFFF3E0).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: controller.isPoseDetected.value ? Colors.green : Colors.orange,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            controller.warningMessage.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.isPoseDetected.value ? Colors.green[800] : Colors.orange[900],
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: 20),

                      // Nama Gerakan
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0056B3),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Peregangan Leher & Bahu',
                        style: TextStyle(
                          color: Color(0xFF4A5568),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Informasi Gerakan (Static instructions)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, size: 18, color: Color(0xFF0056B3)),
                                SizedBox(width: 8),
                                Text(
                                  'Informasi Gerakan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0056B3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.exerciseInstruction,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Repetisi / Pengulangan Gerakan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF0056B3)),
                              SizedBox(width: 8),
                              Text(
                                'Repetisi Gerakan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0056B3),
                                ),
                              ),
                            ],
                          ),
                          Obx(() {
                            final completed = controller.reps.value >= controller.targetReps;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: completed 
                                    ? Colors.green.withOpacity(0.15) 
                                    : const Color(0xFF0056B3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: completed ? Colors.green : const Color(0xFF0056B3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '${controller.reps.value} / ${controller.targetReps}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: completed ? Colors.green[800] : const Color(0xFF0056B3),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Buttons Row
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black.withOpacity(0.08)),
                              ),
                              child: const Icon(Icons.arrow_back_ios, color: Color(0xFF005AB4)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() {
                              final isCompleted = controller.reps.value >= controller.targetReps;
                              return ElevatedButton(
                                onPressed: isCompleted ? () => Get.back() : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0056B3),
                                  disabledBackgroundColor: const Color(0xFF0056B3).withOpacity(0.3),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: isCompleted ? 2 : 0,
                                ),
                                child: Text(
                                  'Selesai',
                                  style: TextStyle(
                                    color: isCompleted ? Colors.white : Colors.white.withOpacity(0.6),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
