import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import '../controllers/stretching_controller.dart';

class StretchingPreviewView extends GetView<StretchingController> {
  const StretchingPreviewView({super.key});

  static const Color primaryBlue = Color(0xFF0056B3);
  static const Color lightBlueBackground = Color(0xFFF0F5FF);
  static const Color instructionBackground = Color(0xFFEEF2F9);

  @override
  Widget build(BuildContext context) {
    final String title = Get.arguments ?? 'Neck Roll';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: primaryBlue),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Smart-Stretching',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image/GIF Card ---
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                color: lightBlueBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE1E8F5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // GIF/Image Placeholder
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Replace with actual GIF asset if available
                        Expanded(
                          child: Center(
                            child: Image.network(
                              'https://cdn-icons-png.flaticon.com/512/2833/2833615.png', // Temporary icon
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Smart',
                              style: TextStyle(
                                color: Color(0xFF1A2B4C),
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Work-Life',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Title and Duration ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2B4C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Peregangan Leher & Bahu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0061D2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        '04:20 s',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Instructions ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: instructionBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'INSTRUKSI',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Putar leher perlahan searah jarum jam. Pastikan bahu tetap rileks dan tidak terangkat. Lakukan gerakan dengan lembut untuk menghindari ketegangan berlebih.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF3C4043),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Info Grid ---
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.fitness_center,
                    label: 'Intensitas',
                    value: 'Rendah',
                    iconColor: Colors.orange[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.flash_on,
                    label: 'Fokus',
                    value: 'Fleksibilitas',
                    iconColor: Colors.blue[400]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Start Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.STRETCHING_DETAIL, arguments: title),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                label: const Text(
                  'Mulai Peregangan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005AB4),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: instructionBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A2B4C),
            ),
          ),
        ],
      ),
    );
  }
}
