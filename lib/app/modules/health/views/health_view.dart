import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/health_controller.dart';

class HealthView extends GetView<HealthController> {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildBMISection(),
            const SizedBox(height: 16),
            _buildHydrationSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── BMI CALCULATOR SECTION ────────────────────────────────────────
  Widget _buildBMISection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFC1C6D5).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header row: Title + Edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI Calculator',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF181C22),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Height & Weight display
                    Obx(() => Row(
                          children: [
                            _buildMeasurementColumn(
                                'HEIGHT', '${controller.height.value.toStringAsFixed(0)} cm'),
                            const SizedBox(width: 24),
                            Container(width: 1, height: 32, color: const Color(0xFFC1C6D5)),
                            const SizedBox(width: 24),
                            _buildMeasurementColumn(
                                'WEIGHT', '${controller.weight.value.toStringAsFixed(0)} kg'),
                          ],
                        )),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showEditModal(Get.context!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005AB4),
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // BMI Result card
          _buildBMIResultCard(),
        ],
      ),
    );
  }

  Widget _buildMeasurementColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF717785),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181C22),
          ),
        ),
      ],
    );
  }

  Widget _buildBMIResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Result',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF717785),
            ),
          ),
          const SizedBox(height: 8),
          // BMI value + category badge
          Row(
            children: [
              Obx(() => Text(
                    controller.bmiResult.value.toString(),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF181C22),
                      letterSpacing: -2,
                      height: 1,
                    ),
                  )),
              const SizedBox(width: 16),
              Obx(() => _buildCategoryBadge()),
            ],
          ),
          const SizedBox(height: 20),
          // BMI scale labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UNDERWEIGHT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF717785),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'NORMAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF717785),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'OBESE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF717785),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // BMI scale bar
          _buildBMIScaleBar(),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    final color = controller.getBmiCategoryColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            controller.bmiCategory.value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIScaleBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Expanded(
            flex: 185,
            child: Container(height: 8, color: const Color(0xFF90CAF9)),
          ),
          Expanded(
            flex: 255,
            child: Container(height: 8, color: const Color(0xFF66BB6A)),
          ),
          Expanded(
            flex: 200,
            child: Container(height: 8, color: const Color(0xFFFFF176)),
          ),
          Expanded(
            flex: 160,
            child: Container(height: 8, color: const Color(0xFFFFA726)),
          ),
          Expanded(
            flex: 200,
            child: Container(height: 8, color: const Color(0xFFEF5350)),
          ),
        ],
      ),
    );
  }

  // ─── HYDRATION SECTION ─────────────────────────────────────────────
  Widget _buildHydrationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFC1C6D5).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Hydration + notification icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hydration',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF181C22),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E8F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  size: 20,
                  color: Color(0xFF414753),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Water drop visual + stats
          Row(
            children: [
              // Water drop visualization
              Obx(() => _buildWaterDrop()),
              const SizedBox(width: 28),
              // Stats + log button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target
                    const Text(
                      'TARGET',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF717785),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          '${controller.targetLiters.value} Liters',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF181C22),
                          ),
                        )),
                    const SizedBox(height: 12),
                    // Intake
                    const Text(
                      'INTAKE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF717785),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          '${controller.intakeLiters.value.toStringAsFixed(1)} Liters',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF005AB4),
                          ),
                        )),
                    const SizedBox(height: 16),
                    // Log 250ml button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.logWater(250),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005AB4),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: const Color(0xFF005AB4).withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Log 250ml',
                          style: TextStyle(
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
          const SizedBox(height: 28),
          // Today's Schedule
          _buildScheduleTimeline(),
        ],
      ),
    );
  }

  Widget _buildWaterDrop() {
    final percentage = controller.hydrationPercentage.value;
    return SizedBox(
      width: 110,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer drop shape (background)
          CustomPaint(
            size: const Size(110, 150),
            painter: _WaterDropPainter(
              fillPercentage: 0,
              backgroundColor: const Color(0xFFE0E2EB),
              fillColor: Colors.transparent,
            ),
          ),
          // Filled drop shape
          CustomPaint(
            size: const Size(110, 150),
            painter: _WaterDropPainter(
              fillPercentage: percentage / 100.0,
              backgroundColor: Colors.transparent,
              fillColor: const Color(0xFF005AB4),
            ),
          ),
          // Percentage text
          Positioned(
            bottom: 40,
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: percentage > 30 ? Colors.white : const Color(0xFF005AB4),
                shadows: percentage > 30
                    ? [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181C22),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  controller.scheduleItems.length * 2 - 1,
                  (index) {
                    if (index.isEven) {
                      final itemIndex = index ~/ 2;
                      final item = controller.scheduleItems[itemIndex];
                      final completed = item['completed'] as bool;
                      return _buildScheduleItem(item['time'] as String, completed);
                    } else {
                      // Connector line
                      final prevCompleted =
                          controller.scheduleItems[index ~/ 2]['completed'] as bool;
                      return Container(
                        width: 20,
                        height: 1,
                        margin: const EdgeInsets.only(bottom: 18),
                        color: prevCompleted
                            ? const Color(0xFFC1C6D5)
                            : const Color(0xFFC1C6D5).withValues(alpha: 0.3),
                      );
                    }
                  },
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildScheduleItem(String time, bool completed) {
    return Opacity(
      opacity: completed ? 1.0 : 0.4,
      child: Column(
        children: [
          Icon(
            Icons.water_drop,
            size: 24,
            color: completed ? const Color(0xFF005AB4) : const Color(0xFF717785),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: completed ? const Color(0xFF181C22) : const Color(0xFF717785),
            ),
          ),
        ],
      ),
    );
  }

  // ─── EDIT BMI MODAL ────────────────────────────────────────────────
  void _showEditModal(BuildContext context) {
    controller.heightTextController.text =
        controller.height.value.toStringAsFixed(0);
    controller.weightTextController.text =
        controller.weight.value.toStringAsFixed(0);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Update Measurements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF181C22),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF717785),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Height input
              _buildInputField(
                label: 'Height (cm)',
                controller: controller.heightTextController,
                hint: '178',
              ),
              const SizedBox(height: 16),
              // Weight input
              _buildInputField(
                label: 'Weight (kg)',
                controller: controller.weightTextController,
                hint: '71',
              ),
              const SizedBox(height: 28),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC1C6D5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF181C22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateMeasurements();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005AB4),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFF005AB4).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF414753),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF9F9FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFC1C6D5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFC1C6D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF005AB4), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ─── CUSTOM WATER DROP PAINTER ─────────────────────────────────────
class _WaterDropPainter extends CustomPainter {
  final double fillPercentage;
  final Color backgroundColor;
  final Color fillColor;

  _WaterDropPainter({
    required this.fillPercentage,
    required this.backgroundColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createDropPath(size);

    // Draw background drop
    if (backgroundColor != Colors.transparent) {
      final bgPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, bgPaint);
    }

    // Draw filled portion
    if (fillColor != Colors.transparent && fillPercentage > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final fillHeight = size.height * fillPercentage;
      final clipRect = Rect.fromLTWH(
        0,
        size.height - fillHeight,
        size.width,
        fillHeight,
      );

      canvas.save();
      canvas.clipRect(clipRect);
      canvas.drawPath(path, fillPaint);
      canvas.restore();
    }
  }

  Path _createDropPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Water drop shape
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.5, 0, w * 0.15, h * 0.45, w * 0.1, h * 0.6);
    path.cubicTo(w * 0.02, h * 0.78, w * 0.15, h, w * 0.5, h);
    path.cubicTo(w * 0.85, h, w * 0.98, h * 0.78, w * 0.9, h * 0.6);
    path.cubicTo(w * 0.85, h * 0.45, w * 0.5, 0, w * 0.5, 0);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.fillColor != fillColor;
  }
}
