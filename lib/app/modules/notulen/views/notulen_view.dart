import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notulen_controller.dart';
import 'notulen_archive_view.dart';
import 'notulen_detail_view.dart';
import '../../todolist/controllers/todolist_controller.dart';

class NotulenView extends GetView<NotulenController> {
  const NotulenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
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
          // Mic / Record Control Buttons
          Obx(() {
            final isRec = controller.isRecording.value;
            final isPaused = controller.hasStopped.value;
            final isProc = controller.isProcessing.value;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pause/Resume Button (shown when recording or paused)
                if (isRec || isPaused) ...[
                  GestureDetector(
                    onTap: isProc
                        ? null
                        : () {
                            if (isRec) {
                              controller.pauseRecording();
                            } else {
                              controller.resumeRecording();
                            }
                          },
                    child: Opacity(
                      opacity: isProc ? 0.6 : 1.0,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isRec
                              ? Colors.orange.shade600
                              : Colors.green.shade600,
                          shape: BoxShape.circle,
                          boxShadow: isProc
                              ? null
                              : [
                                  BoxShadow(
                                    color: (isRec
                                            ? Colors.orange.shade600
                                            : Colors.green.shade600)
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Icon(
                          isRec ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
                
                // Main Button: Mic (to start) or Stop (to stop and upload)
                GestureDetector(
                  onTap: isProc
                      ? null
                      : () {
                          if (isRec || isPaused) {
                            controller.stopRecording();
                          } else {
                            controller.startRecording();
                          }
                        },
                  child: Opacity(
                    opacity: isProc ? 0.6 : 1.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isProc
                            ? const Color(0xFF94A3B8)
                            : ((isRec || isPaused)
                                ? const Color(0xFFDC2626) // merah saat merekam/pause untuk stop
                                : const Color(0xFF005AB4)), // biru saat ready untuk start
                        shape: BoxShape.circle,
                        boxShadow: isProc
                            ? null
                            : [
                                BoxShadow(
                                  color: ((isRec || isPaused)
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF005AB4))
                                      .withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: Icon(
                        (isRec || isPaused) ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
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
          Obx(() {
            final isRec = controller.isRecording.value;
            final isPaused = controller.hasStopped.value;
            final isProc = controller.isProcessing.value;
            final hasText = controller.transcriptionText.value.isNotEmpty;

            String status = 'Siap Merekam';
            Color color = const Color(0xFF717785);

            if (isRec) {
              status = 'Merekam • ${controller.formattedDuration.value}';
              color = const Color(0xFFDC2626);
            } else if (isPaused) {
              status = 'Merekam Ditangguhkan • ${controller.formattedDuration.value}';
              color = Colors.orange.shade700;
            } else if (isProc) {
              status = 'Memproses dengan AI...';
              color = const Color(0xFF005AB4);
            } else if (hasText) {
              status = 'Siap Melanjutkan Rekaman';
              color = const Color(0xFF16A34A);
            }

            return Text(
              status,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            );
          }),
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
                const Icon(Icons.auto_awesome,
                    size: 18, color: Color(0xFF005AB4)),
                const SizedBox(width: 8),
                const Text(
                  'Hasil Transkripsi (Groq AI)',
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
              // Sedang merekam — tampilkan live STT
              if (controller.isRecording.value || controller.hasStopped.value) {
                final live = controller.liveText.value;
                if (live.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Sedang merekam... mulai bicara',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFDC2626),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Text(
                  live,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF414753),
                    height: 1.6,
                  ),
                );
              }
              // Sedang memproses AI
              if (controller.isProcessing.value) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    const AiTypingIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      controller.processingStatusText.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717785),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              // Belum ada transkrip
              if (controller.transcriptionText.value.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Tekan tombol mikrofon untuk mulai merekam. Transkripsi AI akan muncul di sini setelah rekaman selesai.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
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
                controller.isAnalyzing.value ? null : controller.analyzeTranscription,
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
            'REKOMENDASI TUGAS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF717785),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: controller.actionItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final action = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.assignment_outlined,
                              size: 18, color: Color(0xFF005AB4)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF181C22),
                                ),
                              ),
                              Text(
                                'Assigned to ${action.assignee} • Due ${action.dueDate}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF717785),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF717785)),
                          tooltip: 'Edit Rekomendasi',
                          onPressed: () => _showEditRecommendationBottomSheet(
                            context: Get.context!,
                            index: idx,
                            action: action,
                            isDetail: false,
                          ),
                        ),
                        Obx(() {
                          final isAdded = Get.isRegistered<TodolistController>() &&
                              Get.find<TodolistController>().tasks.any((t) => t.title == action.title);
                          return IconButton(
                            icon: Icon(
                              isAdded ? Icons.check_circle : Icons.add_task,
                              color: isAdded ? Colors.green : const Color(0xFF005AB4),
                            ),
                            tooltip: isAdded ? 'Sudah ditambahkan' : 'Tambah ke To-Do',
                            onPressed: isAdded
                                ? null
                                : () => _showAddTodoBottomSheet(Get.context!, action),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
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
                'Judul',
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
                  hintText: 'Masukkan judul',
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
                        // Simpan judul ke controller dulu jika ada
                        if (titleController.text.isNotEmpty) {
                          controller.meetingTitle.value = titleController.text;
                        }
                        controller.saveNotulen();
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
              onPressed: () => Get.to(() => const NotulenArchiveView()),
              child: const Text('Lihat Semua', 
              style: TextStyle(
                color: Color(0xFF005AB4),
                fontWeight: FontWeight.w600,
              ),),
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
                  return GestureDetector(
                    onTap: () async {
                      await controller.loadArchive(archive.id);
                      Get.to(() => const NotulenDetailView());
                    },
                    child: Container(
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
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }

  void _showAddTodoBottomSheet(BuildContext context, ActionItem action) {
    final titleController = TextEditingController(text: action.title);
    
    // Format description with assignee & original due date if present
    String descText = '';
    if (action.assignee.isNotEmpty && action.assignee != 'None' && action.assignee != '-') {
      descText += 'Diserahkan kepada: ${action.assignee}\n';
    }
    if (action.dueDate.isNotEmpty && action.dueDate != 'None' && action.dueDate != '-') {
      descText += 'Tenggat asli AI: ${action.dueDate}';
    }
    final descController = TextEditingController(text: descText.trim());
    
    final selectedDate = DateTime.now().obs;
    final selectedTime = TimeOfDay.now().obs;
    final isPriority = false.obs;

    Get.bottomSheet(
      _buildTodoFormBottomSheet(
        context: context,
        title: 'Tambah Tugas dari AI',
        titleController: titleController,
        descController: descController,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        isPriority: isPriority,
        onSave: () {
          if (titleController.text.trim().isEmpty) return;
          final d = selectedDate.value;
          final t = selectedTime.value;
          final deadline = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          final taskDateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          
          Get.find<TodolistController>().addTask(
            title: titleController.text.trim(),
            description: descController.text.trim(),
            isPriority: isPriority.value,
            deadline: deadline,
            taskDate: taskDateStr,
          );
          
          Get.back();
          Get.snackbar(
            'Tugas Ditambahkan',
            'Tugas berhasil ditambahkan ke Smart To-Do.',
            backgroundColor: const Color(0xFFEFF6FF),
            colorText: const Color(0xFF005AB4),
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildTodoFormBottomSheet({
    required BuildContext context,
    required String title,
    required TextEditingController titleController,
    required TextEditingController descController,
    required Rx<DateTime> selectedDate,
    required Rx<TimeOfDay> selectedTime,
    required RxBool isPriority,
    required VoidCallback onSave,
  }) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Judul Tugas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Apa yang ingin Anda kerjakan?',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Deskripsi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan detail...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Tenggat Waktu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedDate.value,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) selectedDate.value = picked;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text('${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: Get.context!,
                          initialTime: selectedTime.value,
                        );
                        if (picked != null) selectedTime.value = picked;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(selectedTime.value.format(Get.context!), style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Prioritas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.priority_high, size: 20, color: isPriority.value ? Colors.red : Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tandai sebagai Penting',
                        style: TextStyle(
                          fontSize: 14,
                          color: isPriority.value ? Colors.black87 : Colors.grey[600],
                          fontWeight: isPriority.value ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Switch(
                      value: isPriority.value,
                      onChanged: (val) => isPriority.value = val,
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditRecommendationBottomSheet({
    required BuildContext context,
    required int index,
    required ActionItem action,
    required bool isDetail,
  }) {
    final titleController = TextEditingController(text: action.title);
    final assigneeController = TextEditingController(text: action.assignee);
    final dueDateController = TextEditingController(text: action.dueDate);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Rekomendasi Tugas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Judul Tugas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Judul tugas...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Penanggung Jawab (PJ)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: assigneeController,
                decoration: InputDecoration(
                  hintText: 'Nama penanggung jawab...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tenggat Waktu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(
                  hintText: 'Tenggat waktu...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final t = titleController.text.trim();
                    final a = assigneeController.text.trim();
                    final d = dueDateController.text.trim();
                    if (t.isEmpty) return;
                    if (isDetail) {
                      controller.updateDetailActionItem(index, t, a, d);
                    } else {
                      controller.updateActionItem(index, t, a, d);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005AB4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Rekomendasi', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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
