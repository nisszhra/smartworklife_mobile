import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todolist_controller.dart';

class TodolistView extends GetView<TodolistController> {
  const TodolistView({super.key});

  // Nexus UI Color Palette
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color lightBlueBg = Color(0xFFF0F7FF);
  static const Color textGrey = Color(0xFF5F6368);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  // ─── Tampilkan Modal Bottom Sheet "Tambah Tugas" ───────────────────────────
  void _showAddTaskBottomSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final selectedDate = DateTime.now().obs;
    final selectedTime = TimeOfDay.now().obs;
    final isPriority = false.obs;

    Get.bottomSheet(
      _buildBottomSheetWrapper(
        title: 'add_task'.tr,
        titleController: titleController,
        descController: descController,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        isPriority: isPriority,
        onSave: () {
          if (titleController.text.trim().isEmpty) return;
          // Gabungkan tanggal + waktu jadi DateTime untuk deadline
          final d = selectedDate.value;
          final t = selectedTime.value;
          final deadline = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          final taskDateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
          controller.addTask(
            title: titleController.text.trim(),
            description: descController.text.trim(),
            isPriority: isPriority.value,
            deadline: deadline,
            taskDate: taskDateStr,
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── Tampilkan Modal Bottom Sheet "Edit Tugas" ─────────────────────────────
  void _showEditTaskBottomSheet(TodoModel task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    // Pre-fill dari deadline yang ada, atau pakai hari ini
    final initDate = task.deadline?.toLocal() ?? DateTime.now();
    final selectedDate = initDate.obs;
    final selectedTime = TimeOfDay(hour: initDate.hour, minute: initDate.minute).obs;
    final isPriority = task.isPriority.obs;

    Get.bottomSheet(
      _buildBottomSheetWrapper(
        title: 'edit_task'.tr,
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
          controller.updateTask(
            id: task.id,
            title: titleController.text.trim(),
            description: descController.text.trim(),
            isPriority: isPriority.value,
            deadline: deadline,
            taskDate: taskDateStr,
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── Tampilkan Modal Bottom Sheet "Perpanjang Tenggat Waktu" ──────────────────
  void _showExtendDeadlineBottomSheet(TodoModel task) {
    final initDate = DateTime.now().add(const Duration(days: 1));
    final selectedDate = initDate.obs;
    final selectedTime = const TimeOfDay(hour: 9, minute: 0).obs;

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
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 32,
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
                  Text(
                    'extend_deadline'.tr,
                    style: const TextStyle(
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'overdue_desc'.trParams({'title': task.title}),
                        style: TextStyle(fontSize: 13, color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('choose_new_deadline'.tr),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: selectedDate.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) selectedDate.value = picked;
                      },
                      child: _buildDateTimePickerBox(
                        Icons.calendar_today,
                        '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}',
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
                      child: _buildDateTimePickerBox(
                        Icons.access_time,
                        selectedTime.value.format(Get.context!),
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final d = selectedDate.value;
                    final t = selectedTime.value;
                    final deadline = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                    await controller.extendOverdueTask(task: task, newDeadline: deadline);
                    Get.back();
                    Get.snackbar(
                      'success'.tr,
                      'deadline_extended_desc'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'save_extension'.tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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

  Widget _buildBottomSheetWrapper({
    required String title,
    required TextEditingController titleController,
    required TextEditingController descController,
    required Rx<DateTime> selectedDate,
    required Rx<TimeOfDay> selectedTime,
    required RxBool isPriority,
    required VoidCallback onSave,
  }) {
    return Builder(
      builder: (context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        return Container(
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
                _buildLabel('task_title'.tr),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  autofocus: title == 'add_task'.tr,
                  decoration: _getInputDecoration('task_what_to_do'.tr),
                ),
                const SizedBox(height: 20),
                _buildLabel('description_label'.tr),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: _getInputDecoration('task_add_note'.tr),
                ),
                const SizedBox(height: 20),
                _buildLabel('due_date_label'.tr),
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
                        child: _buildDateTimePickerBox(
                          Icons.calendar_today,
                          '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}',
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
                        child: _buildDateTimePickerBox(
                          Icons.access_time,
                          selectedTime.value.format(Get.context!),
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('priority_label'.tr),
                const SizedBox(height: 8),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.priority_high,
                          size: 20,
                          color: isPriority.value ? Colors.red : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'mark_as_important'.tr,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'save_task'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(height: keyboardHeight),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }

  Widget _buildDateTimePickerBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF005AB4), size: 24),
              onPressed: () => Get.back(),
            ),
        ),
        title: const Text(
          'Smart To-Do',
          style: TextStyle(
            color: Color(0xFF005AB4),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // --- Search Bar & Filters ---
          Container(
            color: const Color(0xFFF9F9FF),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterChips(),
              ],
            ),
          ),
          
          // --- Task List ---
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
                );
              }

              // Error state
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 56, color: Color(0xFFBBBBBB)),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF5F6368), fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: controller.fetchTodos,
                        icon: const Icon(Icons.refresh),
                        label: Text('try_again'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final now = DateTime.now();
              final filteredTasks = controller.tasks.where((t) {
                // Search query filter
                if (controller.searchQuery.value.isNotEmpty) {
                  final query = controller.searchQuery.value.toLowerCase();
                  final titleMatch = t.title.toLowerCase().contains(query);
                  final descMatch = t.description.toLowerCase().contains(query);
                  if (!titleMatch && !descMatch) return false;
                }

                // Filter chip
                if (controller.selectedFilter.value == 'Penting') {
                  return t.isPriority;
                } else if (controller.selectedFilter.value == 'Hari Ini') {
                  return t.deadline != null &&
                      t.deadline!.year == now.year &&
                      t.deadline!.month == now.month &&
                      t.deadline!.day == now.day;
                } else if (controller.selectedFilter.value == 'Besok') {
                  final tomorrow = now.add(const Duration(days: 1));
                  return t.deadline != null &&
                      t.deadline!.year == tomorrow.year &&
                      t.deadline!.month == tomorrow.month &&
                      t.deadline!.day == tomorrow.day;
                } else if (controller.selectedFilter.value == 'Terlambat') {
                  return t.isOverdue;
                }
                return true;
              }).toList();

              final activeTasks = filteredTasks.where((t) => !t.isCompleted).toList();
              final completedTasks = filteredTasks.where((t) => t.isCompleted).toList();

              return RefreshIndicator(
                onRefresh: controller.fetchTodos,
                color: const Color(0xFF1A73E8),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    Text(
                      'active_tasks'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (activeTasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'no_active_tasks'.tr,
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ...activeTasks.map((task) => _buildTaskCard(task)),
                    
                    const SizedBox(height: 32),
                    _buildCompletedHeader(),
                    const SizedBox(height: 16),
                    if (controller.isCompletedExpanded.value)
                      ...completedTasks.map((task) => _buildTaskCard(task)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'search_task'.tr,
          hintStyle: const TextStyle(color: Color(0xFF5F6368), fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF5F6368)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['filter_all'.tr, 'filter_important'.tr, 'filter_today'.tr, 'filter_tomorrow'.tr, 'filter_overdue'.tr];
    final filterKeys = ['Semua', 'Penting', 'Hari Ini', 'Besok', 'Terlambat'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
            children: List.generate(filters.length, (index) {
              String filterLabel = filters[index];
              String filterKey = filterKeys[index];
              bool isActive = controller.selectedFilter.value == filterKey;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(filterLabel),
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF5F6368),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  selected: isActive,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedFilter.value = filterKey;
                    }
                  },
                  backgroundColor: const Color(0xFFF1F3F4),
                  selectedColor: const Color(0xFF1A73E8),
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: isActive
                            ? const Color(0xFF1A73E8)
                            : Colors.transparent),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              );
            }),
          )),
    );
  }

  Widget _buildTaskCard(TodoModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isOverdue
              ? Colors.red[200]!
              : const Color(0xFFE0E0E0).withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: task.isOverdue
                ? Colors.red.withOpacity(0.04)
                : Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox Kotak
            GestureDetector(
              onTap: () => controller.toggleTaskStatus(task.id),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: task.isCompleted
                        ? const Color(0xFF1A73E8)
                        : (task.isOverdue ? Colors.red : const Color(0xFFE0E0E0)),
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? const Color(0xFF1A73E8).withOpacity(0.1)
                      : (task.isOverdue ? Colors.red[50] : Colors.white),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Color(0xFF1A73E8))
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // Konten (Bisa diklik untuk Edit / Perpanjang)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (task.isOverdue) {
                    _showExtendDeadlineBottomSheet(task);
                  } else {
                    _showEditTaskBottomSheet(task);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: task.isCompleted ? Colors.grey : Colors.black87,
                        decoration:
                            task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Badge Waktu
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: task.isOverdue
                                ? const Color(0xFFFFEBEE)
                                : (task.isPriority
                                    ? const Color(0xFFFFEBEE)
                                    : const Color(0xFFF1F3F4)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                task.isOverdue
                                    ? Icons.error_outline
                                    : (task.isPriority
                                        ? Icons.calendar_today
                                        : Icons.access_time),
                                size: 14,
                                color: task.isOverdue
                                    ? Colors.red[700]
                                    : (task.isPriority
                                        ? Colors.red[700]
                                        : const Color(0xFF5F6368)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.timeLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: task.isOverdue
                                      ? Colors.red[700]
                                      : (task.isPriority
                                          ? Colors.red[700]
                                          : const Color(0xFF5F6368)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (task.isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'overdue_badge'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (task.isExtended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'extension_badge'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (task.cleanDescription.isNotEmpty)
                          Text(
                            task.cleanDescription,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF5F6368)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF5F6368)),
              onSelected: (val) {
                if (val == 'edit') _showEditTaskBottomSheet(task);
                if (val == 'delete') controller.deleteTask(task.id);
                if (val == 'extend') _showExtendDeadlineBottomSheet(task);
              },
              itemBuilder: (context) => [
                if (task.isOverdue)
                  PopupMenuItem(
                    value: 'extend',
                    child: Row(
                      children: [
                        const Icon(Icons.history, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('extend_deadline_short'.tr),
                      ],
                    ),
                  ),
                PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
                PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedHeader() {
    int count = controller.tasks.where((t) => t.isCompleted).length;
    return GestureDetector(
      onTap: () => controller.isCompletedExpanded.toggle(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            Obx(() => AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: controller.isCompletedExpanded.value ? 0.25 : 0,
                  child: const Icon(Icons.keyboard_arrow_right, color: Color(0xFF5F6368)),
                )),
            const SizedBox(width: 8),
            Text(
              'completed_count'.trParams({'count': count.toString()}),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5F6368),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _showAddTaskBottomSheet(),
      backgroundColor: primaryBlue,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}