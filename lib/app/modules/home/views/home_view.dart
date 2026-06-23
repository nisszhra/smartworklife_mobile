import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/todo_model.dart';
import '../../../routes/app_pages.dart';
import '../../todolist/controllers/todolist_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final todolistController = Get.find<TodolistController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Good Morning, ${Get.find<AuthService>().currentUser.value?.fullName ?? 'User'} 👋',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
              const SizedBox(height: 8),
              Text(
                'Here is your productivity overview for today.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              
              // Productivity Overview Cards
              Obx(() {
                if (controller.isLoading.value && controller.summary.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final summary = controller.summary.value;
                final focusTime = summary?.focusTime ?? 0;
                final breakTime = summary?.breakTime ?? 0;
                final tasksDoneRate = summary?.tasksDoneRate ?? 0.0;

                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Focus Time', _formatDuration(focusTime), Icons.timer, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Break Time', _formatDuration(breakTime), Icons.coffee, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Tasks Done', '${tasksDoneRate.toInt()}%', Icons.check_circle_outline, Colors.green)),
                  ],
                );
              }),
              const SizedBox(height: 32),
              
              // Smart To-Do
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Smart To-Do',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(Routes.TODOLIST),
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Color(0xFF005AB4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFilterChips(),
                      const SizedBox(height: 20),
                      Obx(() {
                        final activeTasks = todolistController.tasks.where((t) {
                          if (t.isCompleted) return false;
                          
                          final now = DateTime.now();
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
                        }).take(3).toList();
                        
                        if (activeTasks.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('Tidak ada tugas aktif', style: TextStyle(color: Colors.grey)),
                            ),
                          );
                        }
                        
                        return Column(
                          children: activeTasks.asMap().entries.map((entry) {
                            int idx = entry.key;
                            TodoModel task = entry.value;
                            return Column(
                              children: [
                                _buildTodoCard(task, todolistController),
                                if (idx < activeTasks.length - 1)
                                  Divider(color: Colors.grey.withOpacity(0.1), height: 1),
                              ],
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Today\'s Balance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Today's Balance Pie Chart
              Obx(() {
                if (controller.isLoading.value && controller.summary.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final summary = controller.summary.value;
                final workPct = summary?.workPercentage ?? 0.0;
                final restPct = summary?.restPercentage ?? 0.0;
                
                // If both are 0, we can just show a default empty chart or a message
                final hasData = (workPct > 0 || restPct > 0);

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: hasData 
                          ? PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFF1A73E8),
                                    value: workPct,
                                    title: '${workPct.toInt()}%',
                                    radius: 20,
                                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xFFFF9800),
                                    value: restPct,
                                    title: '${restPct.toInt()}%',
                                    radius: 20,
                                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          : const Center(child: Text('No Data', style: TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(color: const Color(0xFF1A73E8), label: 'Work (Focus)', value: '${workPct.toInt()}%'),
                            const SizedBox(height: 12),
                            _buildLegendItem(color: const Color(0xFFFF9800), label: 'Rest (Break)', value: '${restPct.toInt()}%'),
                            const SizedBox(height: 16),
                            const Text(
                              'Keep a healthy balance between focus time and breaks to prevent burnout.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required String value}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Penting', 'Hari Ini', 'Besok', 'Terlambat'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: filters.map((filter) {
          bool isActive = controller.selectedFilter.value == filter;
          return GestureDetector(
            onTap: () {
              controller.selectedFilter.value = filter;
            },
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filter,
                      style: TextStyle(
                        color: isActive ? const Color(0xFF1A73E8) : const Color(0xFF5F6368),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 2,
                        color: const Color(0xFF1A73E8),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildTodoCard(TodoModel task, TodolistController todolistController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 12),
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
              onTap: () => todolistController.toggleTaskStatus(task.id),
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
                    _showExtendDeadlineBottomSheet(task, todolistController);
                  } else {
                    _showEditTaskBottomSheet(task, todolistController);
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
                            child: const Text(
                              'Terlambat',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB71C1C),
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
                            child: const Text(
                              'Perpanjangan',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFE65100),
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
                if (val == 'edit') _showEditTaskBottomSheet(task, todolistController);
                if (val == 'delete') todolistController.deleteTask(task.id);
                if (val == 'extend') _showExtendDeadlineBottomSheet(task, todolistController);
              },
              itemBuilder: (context) => [
                if (task.isOverdue)
                  const PopupMenuItem(
                    value: 'extend',
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Perpanjang Tenggat'),
                      ],
                    ),
                  ),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskBottomSheet(TodoModel task, TodolistController todolistController) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    final initDate = task.deadline?.toLocal() ?? DateTime.now();
    final selectedDate = initDate.obs;
    final selectedTime = TimeOfDay(hour: initDate.hour, minute: initDate.minute).obs;
    final isPriority = task.isPriority.obs;

    Get.bottomSheet(
      _buildBottomSheetWrapper(
        title: 'Edit Tugas',
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
          todolistController.updateTask(
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

  void _showExtendDeadlineBottomSheet(TodoModel task, TodolistController todolistController) {
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
                  const Text(
                    'Perpanjang Tenggat Waktu',
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
                        'Tugas "${task.title}" telah melewati tenggat waktu. Perpanjangan tenggat waktu akan otomatis mengubah prioritas tugas ini menjadi Penting.',
                        style: TextStyle(fontSize: 13, color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Pilih Tenggat Baru'),
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
                    await todolistController.extendOverdueTask(task: task, newDeadline: deadline);
                    Get.back();
                    Get.snackbar(
                      'Sukses',
                      'Tenggat waktu berhasil diperpanjang & ditandai Penting!',
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
                  child: const Text(
                    'Simpan Perpanjangan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                _buildLabel('Judul Tugas'),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: _getInputDecoration('Apa yang ingin Anda kerjakan?'),
                ),
                const SizedBox(height: 20),
                _buildLabel('Deskripsi'),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: _getInputDecoration('Tambahkan catatan detail...'),
                ),
                const SizedBox(height: 20),
                _buildLabel('Tenggat Waktu'),
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
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPriority.value ? const Color(0xFFFFEBEE) : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPriority.value ? const Color(0xFFFFCDD2) : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Simpan Tugas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
}
