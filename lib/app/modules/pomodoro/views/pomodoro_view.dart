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
              const Text(
                'Choose Focus Mode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181C22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Customize your work rhythm to meet your needs.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF414753),
            ),
          ),
          const SizedBox(height: 32),

          // Mode Cards
          _buildModeCard(
            mode: PomodoroMode.klasik,
            badgeLabel: 'Klasik',
            badgeIcon: Icons.coffee,
            badgeBgColor: const Color(0xFFD6E3FF),
            badgeTextColor: const Color(0xFF00458D),
            title: '25 mins Work • 5 mins Rest',
            description:
                'Ideal untuk mengelola tugas harian yang dinamis dengan jeda singkat untuk menjaga kesegaran pikiran.',
            buttonLabel: 'Start Session',
            buttonColor: const Color(0xFF005AB4),
            bgIcon: Icons.timer,
          ),
          const SizedBox(height: 16),

          _buildModeCard(
            mode: PomodoroMode.deepWork,
            badgeLabel: 'Deep Work',
            badgeIcon: Icons.bolt,
            badgeBgColor: const Color(0xFFEADDFF),
            badgeTextColor: const Color(0xFF21005D),
            title: '50 mins Work • 10 mins Rest',
            description:
                'Dirancang untuk pekerjaan yang membutuhkan konsentrasi tinggi tanpa gangguan untuk hasil yang mendalam.',
            buttonLabel: 'Start Session',
            buttonColor: const Color(0xFF6750A4),
            bgIcon: Icons.psychology,
          ),
          const SizedBox(height: 16),

          _buildModeCard(
            mode: PomodoroMode.extended,
            badgeLabel: 'Extended',
            badgeIcon: Icons.trending_up,
            badgeBgColor: const Color(0xFFFFDBC9),
            badgeTextColor: const Color(0xFF321200),
            title: '90 mins Work • 30 mins Rest',
            description:
                'Sesi maraton untuk produktivitas maksimal pada proyek besar yang membutuhkan alur kerja yang panjang.',
            buttonLabel: 'Start Session',
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
                  child: ElevatedButton(
                    onPressed: () {
                      controller.startSession(mode);
                      Get.to(() => const PomodoroTimerView());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
