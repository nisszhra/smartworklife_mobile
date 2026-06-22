import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notulen_controller.dart';
import '../../todolist/controllers/todolist_controller.dart';

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
              const Spacer(),
              Obx(() => IconButton(
                    onPressed: controller.detailIsAnalyzing.value
                        ? null
                        : () => controller.analyzeDetailTranscription(),
                    icon: controller.detailIsAnalyzing.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Color(0xFF005AB4),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh, color: Color(0xFF005AB4)),
                    tooltip: 'Analisis Ulang AI Summary',
                  )),
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
                children: controller.detailActionItems.asMap().entries.map((entry) {
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
                              if (action.description.isNotEmpty && action.description != '-')
                                Text(
                                  action.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF414753),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                'Tenggat: ${action.dueDate}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF717785),
                                  fontWeight: FontWeight.w500,
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
                            isDetail: true,
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

  DateTime _parseDueDate(String dueDate) {
    final now = DateTime.now();
    final lower = dueDate.toLowerCase();

    if (lower.contains('hari ini') || lower.contains('today')) {
      return now;
    }
    if (lower.contains('besok') || lower.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    }
    if (lower.contains('lusa') || lower.contains('day after tomorrow')) {
      return now.add(const Duration(days: 2));
    }
    
    // Try to parse dd/MM/yyyy or yyyy-MM-dd
    final dateRegex = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})');
    final match = dateRegex.firstMatch(dueDate);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '') ?? now.day;
      final month = int.tryParse(match.group(2) ?? '') ?? now.month;
      final year = int.tryParse(match.group(3) ?? '') ?? now.year;
      return DateTime(year, month, day);
    }
    
    final isoRegex = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
    final isoMatch = isoRegex.firstMatch(dueDate);
    if (isoMatch != null) {
      final year = int.tryParse(isoMatch.group(1) ?? '') ?? now.year;
      final month = int.tryParse(isoMatch.group(2) ?? '') ?? now.month;
      final day = int.tryParse(isoMatch.group(3) ?? '') ?? now.day;
      return DateTime(year, month, day);
    }

    final idMonths = {
      'januari': 1, 'jan': 1,
      'februari': 2, 'feb': 2,
      'maret': 3, 'mar': 3,
      'april': 4, 'apr': 4,
      'mei': 5,
      'juni': 6, 'jun': 6,
      'juli': 7, 'jul': 7,
      'agustus': 8, 'agu': 8, 'agt': 8,
      'september': 9, 'sep': 9,
      'oktober': 10, 'okt': 10,
      'november': 11, 'nov': 11,
      'desember': 12, 'des': 12,
    };
    
    for (var entry in idMonths.entries) {
      if (lower.contains(entry.key)) {
        final dayRegex = RegExp(r'\b(\d{1,2})\b');
        final yearRegex = RegExp(r'\b(\d{4})\b');
        
        final dayMatch = dayRegex.firstMatch(dueDate);
        final yearMatch = yearRegex.firstMatch(dueDate);
        
        final day = dayMatch != null ? (int.tryParse(dayMatch.group(1) ?? '') ?? now.day) : now.day;
        final year = yearMatch != null ? (int.tryParse(yearMatch.group(1) ?? '') ?? now.year) : now.year;
        final month = entry.value;
        
        return DateTime(year, month, day);
      }
    }

    final enMonths = {
      'january': 1, 'jan': 1,
      'february': 2, 'feb': 2,
      'march': 3, 'mar': 3,
      'april': 4, 'apr': 4,
      'may': 5,
      'june': 6, 'jun': 6,
      'july': 7, 'jul': 7,
      'august': 8, 'aug': 8,
      'september': 9, 'sep': 9,
      'october': 10, 'oct': 10,
      'november': 11, 'nov': 11,
      'december': 12, 'dec': 12,
    };
    
    for (var entry in enMonths.entries) {
      if (lower.contains(entry.key)) {
        final dayRegex = RegExp(r'\b(\d{1,2})\b');
        final yearRegex = RegExp(r'\b(\d{4})\b');
        
        final dayMatch = dayRegex.firstMatch(dueDate);
        final yearMatch = yearRegex.firstMatch(dueDate);
        
        final day = dayMatch != null ? (int.tryParse(dayMatch.group(1) ?? '') ?? now.day) : now.day;
        final year = yearMatch != null ? (int.tryParse(yearMatch.group(1) ?? '') ?? now.year) : now.year;
        final month = entry.value;
        
        return DateTime(year, month, day);
      }
    }

    return now;
  }

  void _showAddTodoBottomSheet(BuildContext context, ActionItem action) {
    final titleController = TextEditingController(text: action.title);
    
    // Format description with action.description
    final descController = TextEditingController(
        text: action.description != '-' ? action.description : '');
    
    final selectedDate = _parseDueDate(action.dueDate).obs;
    final selectedTime = const TimeOfDay(hour: 9, minute: 0).obs;
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
    final descController = TextEditingController(text: action.description);
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
              const Text('Deskripsi Tugas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Deskripsi/detail tugas...',
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
                    final desc = descController.text.trim();
                    final d = dueDateController.text.trim();
                    if (t.isEmpty) return;
                    if (isDetail) {
                      controller.updateDetailActionItem(index, t, desc, d);
                    } else {
                      controller.updateActionItem(index, t, desc, d);
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
