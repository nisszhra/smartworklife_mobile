import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/todo_model.dart';
import '../../../routes/app_pages.dart';
import '../../todolist/controllers/todolist_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final todolistController = Get.find<TodolistController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: SingleChildScrollView(
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
            Row(
              children: [
                Expanded(child: _buildStatCard('Focus Time', '5h 42m', Icons.timer, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Break Time', '45m', Icons.coffee, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Tasks Done', '66%', Icons.check_circle_outline, Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
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
                      final activeTasks = todolistController.tasks.where((t) => !t.isCompleted).take(3).toList();
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Your focus has been peak for 3 hours. Time to take a 5-minute eye-stretch break!",
                      style: TextStyle(color: Colors.blue[900], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            color: Colors.black.withOpacity(0.05),
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
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Penting', 'Hari Ini', 'Besok'];
    return Obx(() => Row(
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
    ));
  }

  Widget _buildTodoCard(TodoModel task, TodolistController todolistController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  color: task.isCompleted ? const Color(0xFF1A73E8) : const Color(0xFFE0E0E0),
                  width: 2,
                ),
                color: task.isCompleted ? const Color(0xFF1A73E8).withOpacity(0.1) : Colors.white,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF1A73E8))
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: task.isCompleted ? Colors.grey : Colors.black87,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Badge Waktu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF5F6368),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.timeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5F6368),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (task.description.isNotEmpty)
                      Expanded(
                        child: Text(
                          task.description,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu Titik Tiga
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF5F6368)),
            onSelected: (val) {
              if (val == 'edit') _showEditTaskBottomSheet(task, todolistController);
              if (val == 'delete') todolistController.deleteTask(task.id);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }

  // --- Bottom Sheet Logic (Copied from TodolistView for consistency) ---
  void _showEditTaskBottomSheet(TodoModel task, TodolistController controller) {
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
          controller.updateTask(
            id: task.id,
            title: titleController.text.trim(),
            description: descController.text.trim(),
            isPriority: isPriority.value,
            deadline: deadline,
          );
          Get.back();
        },
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
                  _buildLabel('Prioritas'),
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
                ],
              ),
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
