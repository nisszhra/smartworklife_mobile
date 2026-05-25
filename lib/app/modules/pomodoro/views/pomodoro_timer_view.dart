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
        automaticallyImplyLeading: false, // Menghilangkan default back button jika diinginkan
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
                Text(
                  'Focus Session ${controller.completedSessions.value + 1} of ${controller.totalTargetSessions.value}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF181C22),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showRestActivitiesBottomSheet(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rest Activities',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: Colors.blue[700], size: 20),
                    ],
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
                  _buildNextStepButton(),
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
        // Back Button (to selection)
        _buildSmallButton(
          icon: Icons.chevron_left,
          onPressed: () {
            controller.stopSession();
            Get.back();
          },
        ),
        const SizedBox(width: 32),
        // Play/Pause Button
        GestureDetector(
          onTap: () => controller.togglePause(),
          child: Container(
            width: 90,
            height: 90,
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
              size: 48,
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Reset Button
        _buildSmallButton(
          icon: Icons.refresh_rounded,
          onPressed: () => controller.resetSession(),
        ),
      ],
    );
  }

  Widget _buildSmallButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            color: Colors.white,
          ),
          child: Icon(icon, color: const Color(0xFF414753), size: 28),
        ),
      ),
    );
  }

  Widget _buildBreakActivities() {
    return Column(
      children: [
        _buildActivityItem(
          icon: Icons.water_drop_rounded,
          iconColor: Colors.blue,
          title: 'Minum Air',
          subtitle: 'Hidrasi tubuh Anda',
          value: controller.hydrateChecked,
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          icon: Icons.restaurant_rounded,
          iconColor: Colors.orange,
          title: 'Makan Ringan',
          subtitle: 'Isi ulang energi Anda',
          value: controller.refuelChecked,
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          icon: Icons.visibility_rounded,
          iconColor: Colors.green,
          title: 'Istirahatkan Mata',
          subtitle: 'Aturan 20-20-20',
          value: controller.eyeRestChecked,
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required RxBool value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF181C22),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717785),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value.value,
              onChanged: (val) => value.value = val ?? false,
              activeColor: Colors.blue[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide(color: Colors.grey[300]!, width: 2),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNextStepButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF0F7FF),
        border: Border.all(
          color: const Color(0xFF005AB4).withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.STRETCHING_DETAIL, arguments: 'Neck Tilt'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005AB4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.accessibility_new_rounded, color: Color(0xFF005AB4), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Step',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF717785),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Lanjut ke Peregangan',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Color(0xFF181C22),
                        ),
                      ),
                      Text(
                        'Optimalkan pemulihan tubuh',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF005AB4), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRestActivitiesBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9FF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aktivitas Istirahat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C22),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lakukan langkah-langkah berikut untuk menjaga kesegaran tubuhmu.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF717785),
              ),
            ),
            const SizedBox(height: 32),
            _buildBreakActivities(),
            const SizedBox(height: 24),
            _buildNextStepButton(),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

