import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notulen_controller.dart';

class NotulenView extends GetView<NotulenController> {
  const NotulenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        title: const Text(
          'Smart Notulen',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF005AB4),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveMeetingCard(),
            const SizedBox(height: 24),
            _buildAISummarySection(),
            const SizedBox(height: 24),
            _buildArchivedMeetingsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.toggleRecording,
            backgroundColor: controller.isRecording.value
                ? const Color(0xFFDC2626) // Red when recording
                : const Color(0xFF005AB4), // Blue when idle
            icon: Icon(
              controller.isRecording.value ? Icons.stop : Icons.mic,
              color: Colors.white,
            ),
            label: Text(
              controller.isRecording.value ? 'Berhenti' : 'Mulai Rekam',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
    );
  }

  Widget _buildActiveMeetingCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            controller.meetingTitle.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF181C22),
                            ),
                          )),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Obx(() => Icon(
                                Icons.fiber_manual_record,
                                size: 12,
                                color: controller.isRecording.value
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF94A3B8),
                              )),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                                controller.isRecording.value
                                    ? 'Recording • ${controller.formattedDuration}'
                                    : 'Idle',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: controller.isRecording.value
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF717785),
                                  fontWeight: FontWeight.w500,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit,
                      size: 20, color: Color(0xFF414753)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Transcription Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.record_voice_over,
                        size: 16, color: Color(0xFF005AB4)),
                    const SizedBox(width: 8),
                    const Text(
                      'Live Transcription',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF005AB4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      controller.transcriptionText.value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF414753),
                        height: 1.5,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome,
                size: 20, color: Color(0xFF6750A4)), // Deep work theme color
            const SizedBox(width: 8),
            const Text(
              'AI Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181C22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Key Insights List
        const Text(
          'Key Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF414753),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: controller.keyInsights
                  .map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 18, color: Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                insight.text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF414753),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            )),

        const SizedBox(height: 16),
        // Action Items Grid
        const Text(
          'Action Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF414753),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: controller.actionItems
                  .map((action) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFCBD5E1), width: 2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF181C22),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Assigned to ${action.assignee} • Due ${action.dueDate}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF717785),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildArchivedMeetingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.folder, size: 20, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            const Text(
              'Arsip Notulen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF181C22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Column(
              children: controller.archivedMeetings
                  .map((archive) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    archive.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF181C22),
                                    ),
                                  ),
                                ),
                                Text(
                                  archive.date,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF717785),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              archive.preview,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF414753),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 14, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text(
                                  archive.duration,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF717785),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}
