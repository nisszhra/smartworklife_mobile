import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF9F9FF);
    const Color textDark = Color(0xFF181C22);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'privacy_policy_terms'.tr,
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
              'privacy_policy_title'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'last_updated'.tr,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'privacy_section1_title'.tr,
              content: 'privacy_section1_desc'.tr,
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'privacy_section2_title'.tr,
              content: 'privacy_section2_desc'.tr,
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'privacy_section3_title'.tr,
              content: 'privacy_section3_desc'.tr,
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'privacy_section4_title'.tr,
              content: 'privacy_section4_desc'.tr,
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'privacy_section5_title'.tr,
              content: 'privacy_section5_desc'.tr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C22),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
