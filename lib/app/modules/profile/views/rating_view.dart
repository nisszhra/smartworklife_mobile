import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rating_controller.dart';

class RatingView extends StatelessWidget {
  const RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller in memory
    final controller = Get.put(RatingController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF005AB4)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Feedback & Rating',
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
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF005AB4)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: controller.features.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final feature = controller.features[index];
            final currentRating = controller.getRatingFor(feature);

            return Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF181C22),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (starIndex) {
                      final starValue = starIndex + 1;
                      final isSelected = starValue <= currentRating;
                      
                      return GestureDetector(
                        onTap: () {
                          if (controller.isSubmitting.value) return;
                          controller.submitRating(feature, starValue);
                        },
                        child: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          size: 36,
                          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFC1C6D5),
                        ),
                      );
                    }),
                  ),
                  if (currentRating > 0) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Tersimpan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
