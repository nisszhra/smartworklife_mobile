import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notulen_controller.dart';

class NotulenDetailView extends GetView<NotulenController> {
  const NotulenDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181C22)),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          if (controller.detailIsEditing.value) {
            return TextField(
              controller: controller.detailTitleController,
              decoration: const InputDecoration(
                hintText: 'Ubah Judul',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: Color(0xFF181C22),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          }
          return Text(
            controller.detailTitle.value,
            style: const TextStyle(
              color: Color(0xFF181C22),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.detailIsEditing.value
                      ? Icons.check_circle
                      : Icons.edit,
                  color: const Color(0xFF005AB4),
                ),
                onPressed: controller.toggleEditDetailTranscription,
              )),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: Obx(() {
        final isProc = controller.isProcessing.value;
        final isAnal = controller.detailIsAnalyzing.value;

        if (isProc) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AiTypingIndicator(),
                const SizedBox(height: 16),
                Text(
                  controller.processingStatusText.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717785),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMeetingMetaDataCard(),
              const SizedBox(height: 24),
              _buildTranscriptionCard(),
              const SizedBox(height: 24),
              if (controller.detailShowAiSummary.value) ...[
                _buildAISummarySection(),
              ] else ...[
                _buildGenerateSummaryCard(),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMeetingMetaDataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_note, color: Color(0xFF005AB4), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pertemuan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF717785),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      'Durasi Rekaman: ${controller.detailDuration.value}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF181C22),
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC1C6D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, size: 18, color: Color(0xFF005AB4)),
                const SizedBox(width: 8),
                const Text(
                  'Transkripsi Suara',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF005AB4),
                  ),
                ),
                const Spacer(),
                Obx(() => IconButton(
                      onPressed: controller.toggleEditDetailTranscription,
                      icon: Icon(
                        controller.detailIsEditing.value
                            ? Icons.check_circle_outline
                            : Icons.edit_note,
                        color: const Color(0xFF414753),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              if (controller.detailIsEditing.value) {
                return TextField(
                  controller: controller.detailTranscriptionController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Edit transkripsi...',
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF414753),
                    height: 1.5,
                  ),
                );
              }
              return Text(
                controller.detailTranscript.value.isEmpty
                    ? 'Tidak ada teks transkripsi.'
                    : controller.detailTranscript.value,
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

  Widget _buildGenerateSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, size: 48, color: Color(0xFF005AB4)),
          const SizedBox(height: 16),
          const Text(
            'Buat Ringkasan AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181C22),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gunakan AI untuk menganalisis transkripsi dan menghasilkan ringkasan poin penting serta action items secara otomatis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF717785),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.detailIsAnalyzing.value
                      ? null
                      : () => controller.analyzeDetailTranscription(),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: controller.detailIsAnalyzing.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Analisis AI Summary',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005AB4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                )),
          ),
        ],
      ),
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
          Obx(() => Column(
                children: controller.detailInsights
                    .map((insight) => Padding(
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
                        ))
                    .toList(),
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
          Obx(() => Column(
                children: controller.detailActionItems
                    .map((action) => Container(
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
                        ))
                    .toList(),
              )),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Notulen?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Apakah Anda yakin ingin menghapus notulen ini secara permanen?',
          style: TextStyle(color: Color(0xFF717785)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF717785))),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteNotulen(controller.detailNotulenId.value);
      Get.back(); // Go back from detail view
    }
  }
}

class AiTypingIndicator extends StatefulWidget {
  const AiTypingIndicator({super.key});

  @override
  State<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              transform: Matrix4.translationValues(
                0.0,
                -6.0 * _animations[index].value,
                0.0,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF005AB4),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
