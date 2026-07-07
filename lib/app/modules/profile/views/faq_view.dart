import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqView extends StatelessWidget {
  const FaqView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF9F9FF);
    const Color primary = Color(0xFF005AB4);
    const Color textDark = Color(0xFF181C22);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'faq_title'.tr,
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'feature_guide'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildGuideCard(
              icon: Icons.mic_none_outlined,
              title: 'Smart Notulen', 
              description: 'guide_notulen_desc'.tr,
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.timer_outlined,
              title: 'Pomodoro Timer',
              description: 'guide_pomodoro_desc'.tr,
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.fitbit_outlined,
              title: 'Stretching & Hidrasi',
              description: 'guide_health_desc'.tr,
            ),
            const SizedBox(height: 32),
            Text(
              'general_faq'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqTile(
              question: 'faq_q1'.tr,
              answer: 'faq_a1'.tr,
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            _buildFaqTile(
              question: 'faq_q2'.tr,
              answer: 'faq_a2'.tr,
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            _buildFaqTile(
              question: 'faq_q3'.tr,
              answer: 'faq_a3'.tr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC1C6D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF005AB4), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181C22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile({
    required String question,
    required String answer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181C22),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
