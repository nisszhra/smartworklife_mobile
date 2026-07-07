import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class PreferensiUserView extends GetView<ProfileController> {
  const PreferensiUserView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF9F9FF);
    const Color primary = Color(0xFF005AB4);
    const Color textDark = Color(0xFF181C22);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'user_preferences'.tr,
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
            // ─── HEALTH INFO ───────────────────────────────────────────
            Container(
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
              child: Obx(() => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.health_and_safety_outlined, size: 20, color: primary),
                        const SizedBox(width: 8),
                        Text(
                          'health_profile'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'age'.tr,
                            controller: controller.ageController,
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'gender'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF717785),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.gender.value,
                                    isExpanded: true,
                                    items: ['Laki-laki', 'Perempuan'].map((String value) {
                                      final displayValue = value == 'Laki-laki' ? 'male'.tr : 'female'.tr;
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(displayValue, style: const TextStyle(fontSize: 15)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) controller.setGender(val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'weight_kg'.tr,
                            controller: controller.weightController,
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'height_cm'.tr,
                            controller: controller.heightController,
                            icon: Icons.height_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ),
            const SizedBox(height: 24),
            // ─── WORK INFO ─────────────────────────────────────────────
            Container(
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
              child: Obx(() => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.work_outline, size: 20, color: primary),
                        const SizedBox(width: 8),
                        Text(
                          'work_profile'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'industry'.tr,
                      controller: controller.industryController,
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'start_work'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF717785),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: GestureDetector(
                                  onTap: () => controller.selectStartTime(context),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.startTime.value,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const Icon(Icons.access_time, size: 18, color: Color(0xFF94A3B8)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'end_work'.tr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF717785),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: GestureDetector(
                                  onTap: () => controller.selectEndTime(context),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        controller.endTime.value,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const Icon(Icons.access_time, size: 18, color: Color(0xFF94A3B8)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ),
            const SizedBox(height: 32),
            // ─── SAVE BUTTON ───────────────────────────────────────────
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (controller.isSaving.value || !controller.hasChanges.value)
                    ? null
                    : controller.saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'save_preferences'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF717785),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF181C22),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF9F9FF),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF005AB4), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
