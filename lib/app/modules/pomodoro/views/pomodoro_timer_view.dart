import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pomodoro_controller.dart';
import '../../../routes/app_pages.dart';

class PomodoroTimerView extends GetView<PomodoroController> {
  const PomodoroTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        title: const Text(
          'Pomodoro Timer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF005AB4),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF005AB4)),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        final isWorking = controller.pomodoroState.value == PomodoroState.working;
        
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Timer Circle
                _buildTimerCircle(isWorking),
                const SizedBox(height: 40),
                
                // Session Info
                // Session Info
                Text(
                  isWorking 
                      ? 'Focus Session ${controller.completedSessions.value + 1} of ${controller.totalTargetSessions.value}'
                      : 'Rest Time ${controller.completedSessions.value + 1} of ${controller.totalTargetSessions.value}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181C22),
                  ),
                ),
                const SizedBox(height: 32),

                // Controls
                _buildControls(),
                
                const SizedBox(height: 48),

                // Break Activities (only show during break)
                if (controller.pomodoroState.value == PomodoroState.breaking) ...[
                  _buildBreakActivities(),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimerCircle(bool isWorking) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isWorking ? const Color(0xFF005AB4) : const Color(0xFF4CAF50)).withOpacity(0.05),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Progress Circle
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              color: const Color(0xFFE6E8F1),
              strokeCap: StrokeCap.round,
            ),
          ),
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: controller.progress,
              strokeWidth: 12,
              color: isWorking ? const Color(0xFF005AB4) : const Color(0xFF4CAF50),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Timer Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.formattedTime,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF181C22),
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isWorking ? 'FOCUS' : 'REST',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF717785),
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop Button
        GestureDetector(
          onTap: () {
            controller.stopSession();
            Get.back();
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444), // Merah untuk stop
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.stop_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Play/Pause Button
        GestureDetector(
          onTap: () => controller.togglePause(),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF005AB4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005AB4).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              controller.isPaused.value ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakActivities() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF005AB4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_cafe_rounded, color: Color(0xFF005AB4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waktunya Istirahat!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181C22),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fokus selesai, segarkan diri sejenak.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallActivityItem(Icons.local_drink_rounded, 'MINUM'),
              _buildSmallActivityItem(Icons.restaurant_rounded, 'MAKAN'),
              _buildSmallActivityItem(Icons.visibility_rounded, 'PANDANG'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Mulai Stretching Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.STRETCHING, arguments: {'fromPomodoro': true}),
              icon: const Icon(Icons.fitness_center_rounded, color: Colors.white),
              label: const Text(
                'Mulai Stretching',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005AB4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActivityItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF005AB4).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF005AB4).withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF005AB4), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF717785),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

