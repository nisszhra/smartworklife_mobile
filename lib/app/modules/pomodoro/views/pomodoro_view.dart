import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pomodoro_controller.dart';
import 'pomodoro_timer_view.dart';

class PomodoroView extends GetView<PomodoroController> {
  const PomodoroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: _buildModeSelectionView(),
    );
  }


  // ─── MODE SELECTION VIEW ─────────────────────────────────────────
  Widget _buildModeSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFF005AB4), size: 20),
              const SizedBox(width: 8),
              Text(
                'choose_focus_mode'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181C22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'customize_work_rhythm'.tr,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF414753),
            ),
          ),
          const SizedBox(height: 32),

          // Mode Cards
          _buildModeCard(
            mode: PomodoroMode.klasik,
            badgeLabel: 'classic'.tr,
            badgeIcon: Icons.coffee,
            badgeBgColor: const Color(0xFFD6E3FF),
            badgeTextColor: const Color(0xFF00458D),
            title: '25 mins Work • 5 mins Rest',
            description: 'classic_desc'.tr,
            buttonLabel: 'start_session'.tr,
            buttonColor: const Color(0xFF005AB4),
            bgIcon: Icons.timer,
          ),
          const SizedBox(height: 16),

          _buildModeCard(
            mode: PomodoroMode.deepWork,
            badgeLabel: 'deep_work'.tr,
            badgeIcon: Icons.bolt,
            badgeBgColor: const Color(0xFFEADDFF),
            badgeTextColor: const Color(0xFF21005D),
            title: '50 mins Work • 10 mins Rest',
            description: 'deep_work_desc'.tr,
            buttonLabel: 'start_session'.tr,
            buttonColor: const Color(0xFF6750A4),
            bgIcon: Icons.psychology,
          ),
          const SizedBox(height: 16),

          _buildModeCard(
            mode: PomodoroMode.extended,
            badgeLabel: 'extended'.tr,
            badgeIcon: Icons.trending_up,
            badgeBgColor: const Color(0xFFFFDBC9),
            badgeTextColor: const Color(0xFF321200),
            title: '90 mins Work • 30 mins Rest',
            description: 'extended_desc'.tr,
            buttonLabel: 'start_session'.tr,
            buttonColor: const Color(0xFF964400),
            bgIcon: Icons.directions_run,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required PomodoroMode mode,
    required String badgeLabel,
    required IconData badgeIcon,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required String title,
    required String description,
    required String buttonLabel,
    required Color buttonColor,
    required IconData bgIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC1C6D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background icon
          Positioned(
            top: 16,
            right: 16,
            child: Icon(
              bgIcon,
              size: 64,
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 18, color: badgeTextColor),
                      const SizedBox(width: 6),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: badgeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF181C22),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF414753),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Start button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final isActive = controller.selectedMode.value == mode &&
                        controller.pomodoroState.value != PomodoroState.idle;
                    final isAnotherActive = controller.selectedMode.value != null &&
                        controller.selectedMode.value != mode &&
                        controller.pomodoroState.value != PomodoroState.idle;

                    return ElevatedButton(
                      onPressed: () {
                        if (isActive) {
                          Get.to(() => const PomodoroTimerView());
                        } else if (isAnotherActive) {
                          Get.snackbar(
                            'active_session_title'.tr,
                            'active_session_desc'.tr,
                            backgroundColor: Colors.red[50],
                            colorText: Colors.red[900],
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            icon: Icon(Icons.warning_rounded, color: Colors.red[900]),
                          );
                        } else {
                          _showSessionBottomSheet(mode);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? const Color(0xFF4CAF50) : buttonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isActive ? 'resume_session'.tr : buttonLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionBottomSheet(PomodoroMode mode) {
    final sessions = 1.obs;

    String title = '';
    String description = '';
    int workMins = 0;
    int breakMins = 0;

    switch (mode) {
      case PomodoroMode.klasik:
        title = 'set_classic_session'.tr;
        description = 'classic_session_info'.tr;
        workMins = 25;
        breakMins = 5;
        break;
      case PomodoroMode.deepWork:
        title = 'set_deep_work_session'.tr;
        description = 'deep_work_session_info'.tr;
        workMins = 50;
        breakMins = 10;
        break;
      case PomodoroMode.extended:
        title = 'set_extended_session'.tr;
        description = 'extended_session_info'.tr;
        workMins = 90;
        breakMins = 30;
        break;
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C22),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF717785),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'session_count'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF181C22),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (sessions.value > 1) sessions.value--;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(Icons.remove, size: 18, color: Color(0xFF414753)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Obx(() => Text(
                            '${sessions.value}x',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005AB4),
                            ),
                          )),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          sessions.value++;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(Icons.add, size: 18, color: Color(0xFF414753)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final totalMinutes = sessions.value * (workMins + breakMins);
              final hours = totalMinutes ~/ 60;
              final mins = totalMinutes % 60;
              final timeString = hours > 0
                  ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
                  : '${mins}m';
                  
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF005AB4), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'total_time_info'.trParams({
                          'time': timeString,
                          'sessions': sessions.value.toString()
                        }),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF00458D),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.startSession(mode, sessions: sessions.value);
                  Get.to(() => const PomodoroTimerView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005AB4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'start_now'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

}
