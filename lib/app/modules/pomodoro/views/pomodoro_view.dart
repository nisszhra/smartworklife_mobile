import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pomodoro_controller.dart';

class PomodoroView extends GetView<PomodoroController> {
  const PomodoroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        title: const Text(
          'Smart-Health',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF005AB4),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.pomodoroState.value != PomodoroState.idle) {
          return _buildTimerView();
        }
        return _buildModeSelectionView();
      }),
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
                'Pilih Mode Fokus',
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
            'Sesuaikan ritme kerja dengan kebutuhanmu',
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
            title: '25 menit kerja • 5 menit istirahat',
            description:
                'Ideal untuk mengelola tugas harian yang dinamis dengan jeda singkat untuk menjaga kesegaran pikiran.',
            buttonLabel: 'Mulai Sesi Klasik',
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
            title: '50 menit kerja • 10 menit istirahat',
            description:
                'Dirancang untuk pekerjaan yang membutuhkan konsentrasi tinggi tanpa gangguan untuk hasil yang mendalam.',
            buttonLabel: 'Mulai Sesi Deep Work',
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
            title: '90 menit kerja • 30 menit istirahat',
            description:
                'Sesi maraton untuk produktivitas maksimal pada proyek besar yang membutuhkan alur kerja yang panjang.',
            buttonLabel: 'Mulai Sesi Extended',
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
                    onPressed: () => controller.startSession(mode),
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

  // ─── TIMER VIEW (Active Session) ─────────────────────────────────
  Widget _buildTimerView() {
    final mode = controller.selectedMode.value!;
    final isWorking =
        controller.pomodoroState.value == PomodoroState.working;

    Color themeColor;
    String modeLabel;
    switch (mode) {
      case PomodoroMode.klasik:
        themeColor = const Color(0xFF005AB4);
        modeLabel = 'Klasik';
        break;
      case PomodoroMode.deepWork:
        themeColor = const Color(0xFF6750A4);
        modeLabel = 'Deep Work';
        break;
      case PomodoroMode.extended:
        themeColor = const Color(0xFF964400);
        modeLabel = 'Extended';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                modeLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // State label
            Text(
              isWorking ? 'Waktu Fokus' : 'Waktu Istirahat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isWorking
                    ? const Color(0xFF181C22)
                    : const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 40),
            // Timer circle
            Obx(() => SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          color: const Color(0xFFE6E8F1),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: controller.progress,
                          strokeWidth: 10,
                          color: isWorking ? themeColor : const Color(0xFF4CAF50),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Timer text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.formattedTime,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF181C22),
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                'Sesi ${controller.completedSessions.value + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF717785),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 48),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stop button
                OutlinedButton(
                  onPressed: () => controller.stopSession(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC1C6D5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                  child: const Text(
                    'Berhenti',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF181C22),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Session info
            Obx(() => Text(
                  '${controller.completedSessions.value} sesi selesai hari ini',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717785),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
