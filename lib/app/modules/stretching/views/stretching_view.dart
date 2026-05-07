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
            // --- Header ---
            _buildHeader(),
            const SizedBox(height: 24),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                _buildExerciseCard(
                  title: 'Neck Tilt',
                  subtitle: 'Miring Leher',
                  imagePath: 'assets/images/Neck Tilt.png',
                ),
                _buildExerciseCard(
                  title: 'Shoulder Rolls',
                  subtitle: 'Putar Bahu',
                  imagePath: 'assets/images/Shoulder rolls.png',
                ),
                _buildExerciseCard(
                  title: 'Upper Back',
                  subtitle: 'Punggung Atas',
                  icon: Icons.accessibility_new,
                ),
                _buildExerciseCard(
                  title: 'Seated Twist',
                  subtitle: 'Putar Duduk',
                  icon: Icons.event_seat,
                ),
                _buildExerciseCard(
                  title: 'Wrist Circle',
                  subtitle: 'Putar Pergelangan',
                  icon: Icons.pan_tool,
                ),
                _buildExerciseCard(
                  title: 'Hamstring',
                  subtitle: 'Otot Paha',
                  icon: Icons.directions_walk,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stretching Recommendations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181C22),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Tingkatkan produktivitas dengan peregangan singkat.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF717785),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required String subtitle,
    String? imagePath,
    IconData? icon,
  }) {
    // Uniform gradient like Wrist Circle
    const List<Color> gradientColors = [Color(0xFFA1C4FD), Color(0xFFC2E9FB)];

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.STRETCHING_PREVIEW, arguments: title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Center(
                  child: imagePath != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Image.asset(
                            imagePath, 
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Icon(icon ?? Icons.self_improvement, size: 48, color: Colors.white.withOpacity(0.9)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, letterSpacing: 0.5),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF717785), fontSize: 11, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
