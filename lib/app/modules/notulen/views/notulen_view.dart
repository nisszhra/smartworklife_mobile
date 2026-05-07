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
            _buildRecordingCard(),
            const SizedBox(height: 24),
            _buildActiveMeetingCard(),
            const SizedBox(height: 24),
            _buildAnalysisButton(),
            Obx(() => controller.showAiSummary.value
                ? Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildAISummarySection(),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 40),
            _buildArchivedMeetingsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC1C6D5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Waveform Placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              12,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: [12, 18, 24, 16, 28, 20, 24, 16, 20, 14, 10, 8][index]
                    .toDouble(),
                decoration: BoxDecoration(
                  color: const Color(0xFF005AB4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Mic Button
          Obx(() => GestureDetector(
                onTap: controller.toggleRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: controller.isRecording.value
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF005AB4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (controller.isRecording.value
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF005AB4))
                            .withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    controller.isRecording.value ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              )),
          const SizedBox(height: 20),
          Obx(() => Text(
                controller.meetingTitle.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181C22),
                ),
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.isRecording.value
                    ? 'Recording • ${controller.formattedDuration}'
                    : 'Ready to Record',
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
    );
  }

  Widget _buildActiveMeetingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC1C6D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over,
                    size: 18, color: Color(0xFF005AB4)),
                const SizedBox(width: 8),
                const Text(
                  'Live Transcription',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF005AB4),
                  ),
                ),
                const Spacer(),
                Obx(() => IconButton(
                      onPressed: controller.toggleEditTranscription,
                      icon: Icon(
                        controller.isEditingTranscription.value
                            ? Icons.check_circle_outline
                            : Icons.edit_note,
                        color: const Color(0xFF414753),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Transcription Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              if (controller.isEditingTranscription.value) {
                return TextField(
                  controller: controller.transcriptionController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Edit transcription...',
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF414753),
                    height: 1.5,
                  ),
                );
              }
              return Text(
                controller.transcriptionText.value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF414753),
                  height: 1.5,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed:
                controller.isAnalyzing.value ? null : controller.analyzeSummary,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005AB4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: controller.isAnalyzing.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Analisis AI Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          )),
    );
  }

  Widget _buildAISummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC1C6D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 20, color: Color(0xFF005AB4)),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181C22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'KEY INSIGHTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF717785),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.keyInsights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 20, color: Color(0xFF005AB4)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF181C22),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          const Text(
            'ACTION ITEMS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF717785),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.actionItems.map((action) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF94A3B8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF181C22),
                            ),
                          ),
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
              )),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showSaveDialog,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF005AB4), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Simpan Notulen',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF005AB4),
          ),
        ),
      ),
    );
  }

  void _showSaveDialog() {
    final titleController =
        TextEditingController(text: controller.meetingTitle.value);
    final dateController =
        TextEditingController(text: DateTime.now().toString().split(' ')[0]);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: Get.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E3FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.save_as, color: Color(0xFF005AB4)),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Simpan Notulen',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181C22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Judul Rapat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF717785),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul rapat',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF005AB4), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF717785),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    dateController.text = date.toString().split(' ')[0];
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today,
                      size: 20, color: Color(0xFF005AB4)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF717785),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.saveNotulen(
                            titleController.text, dateController.text);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005AB4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.bold),
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


  Widget _buildArchivedMeetingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            TextButton(
              onPressed: () {
                // Navigate to archived meetings list page
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.archivedMeetings.length,
                itemBuilder: (context, index) {
                  final archive = controller.archivedMeetings[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              archive.date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF717785),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            archive.preview,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF414753),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              archive.duration,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF717785),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }

}
