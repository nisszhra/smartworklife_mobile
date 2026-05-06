import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import '../controllers/stretching_controller.dart';

class StretchingView extends GetView<StretchingController> {
  const StretchingView({super.key});

  static const Color primaryBlue = Color(0xFF1A73E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Smart Stretching',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF005AB4),
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Banner Utama ---
            _buildMainBanner(),
            const SizedBox(height: 30),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildExerciseCard(
                  title: 'Neck Tilt',
                  duration: '5 MINS',
                  icon: Icons.self_improvement,
                  color: const Color(0xFFE3F2FD),
                  iconColor: Colors.blue[700]!,
                ),
                _buildExerciseCard(
                  title: 'Shoulder Rolls',
                  duration: '3 MINS',
                  icon: Icons.sync,
                  color: const Color(0xFFE3F2FD),
                  iconColor: Colors.green[700]!,
                ),
                _buildExerciseCard(
                  title: 'Upper Back',
                  duration: '4 MINS',
                  icon: Icons.accessibility_new,
                  color: const Color(0xFFE3F2FD),
                  iconColor: Colors.purple[700]!,
                ),
                _buildExerciseCard(
                  title: 'Seated Twist',
                  duration: '6 MINS',
                  icon: Icons.event_seat,
                  color: const Color(0xFFE3F2FD),
                  iconColor: Colors.orange[700]!,
                ),
                _buildExerciseCard(
                  title: 'Wrist Circle',
                  duration: '2 MINS',
                  icon: Icons.pan_tool,
                  color: const Color(0xFFE3F2FD),
                  iconColor: Colors.teal[700]!,
                ),
                _buildExerciseCard(
                  title: 'Hamstring',
                  duration: '5 MINS',
                  icon: Icons.directions_walk,
                  color: const Color(0xFFE3F2FD),
                  iconColor: Colors.red[700]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage('https://cdn-icons-png.flaticon.com/512/2833/2833615.png'),
          alignment: Alignment.centerRight,
          opacity: 0.1,
          scale: 4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '6 FOCUSED EXERCISES',
              style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'List Stretching\nRekomendasi',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tingkatkan produktivitas dengan\nperegangan singkat.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required String duration,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.STRETCHING_DETAIL, arguments: title),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              duration,
              style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
