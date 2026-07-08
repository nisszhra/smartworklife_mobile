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

    final Map<String, String> subtitleMap = {
      'Neck Tilt': 'neck_tilt_sub'.tr,
      'Shoulder Rolls': 'shoulder_rolls_sub'.tr,
      'Upper Back': 'upper_back_sub'.tr,
      'Seated Twist': 'seated_twist_sub'.tr,
      'Wrist Circle': 'wrist_circle_sub'.tr,
      'Hamstring': 'hamstring_sub'.tr,
    };
    final String subtitle = subtitleMap[title] ?? 'neck_tilt_sub'.tr;

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
                      controller.isPoseDetected.value ? 'pose_detected'.tr : 'pose_not_detected'.tr,
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
                      // ── Hold Timer (hanya untuk timer-based exercise) ──
                      Obx(() {
                        if (!controller.isTimerBased) return const SizedBox(height: 20);
                        final holding = controller.isHolding.value;
                        final secs = controller.holdSeconds.value;
                        final target = controller.targetHoldSeconds;
                        final progress = holding ? (secs / target).clamp(0.0, 1.0) : 0.0;
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: holding
                                      ? const Color(0xFF0056B3).withOpacity(0.5)
                                      : Colors.grey.withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'hold_duration'.tr,
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${secs}s / ${target}s',
                                        style: TextStyle(
                                          color: holding ? const Color(0xFF0056B3) : Colors.grey[500],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.blue.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        holding ? const Color(0xFF0056B3) : Colors.grey.shade300,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                      // ──────────────────────────────────────────────────────
                      const SizedBox(height: 4),

                      // Title & Repetisi Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: Color(0xFF0056B3),
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Obx(() {
                            final completed = controller.reps.value >= controller.targetReps;
                            final label = controller.isTimerBased
                                ? 'Set ${controller.reps.value} / ${controller.targetReps}'
                                : '${controller.reps.value} / ${controller.targetReps} Rep';
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
                                label,
                                style: TextStyle(
                                  fontSize: 15,
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
                                  'done_btn'.tr,
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
