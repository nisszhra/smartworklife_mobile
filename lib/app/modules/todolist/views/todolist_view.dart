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
        title: 'Tambah Tugas',
        titleController: titleController,
        descController: descController,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        isPriority: isPriority,
        onSave: () {
          if (titleController.text.trim().isEmpty) return;
          final timeLabel = '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year} ${selectedTime.value.format(Get.context!)}';
          controller.addTask(
            title: titleController.text.trim(),
            description: descController.text.trim(),
            time: timeLabel,
            isPriority: isPriority.value,
          );
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── Tampilkan Modal Bottom Sheet "Edit Tugas" ─────────────────────────────
  void _showEditTaskBottomSheet(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    final selectedDate = DateTime.now().obs;
    final selectedTime = TimeOfDay.now().obs;
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
          final timeLabel = '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year} ${selectedTime.value.format(Get.context!)}';
          controller.updateTask(
            id: task.id,
            title: titleController.text.trim(),
            description: descController.text.trim(),
            time: timeLabel,
            isPriority: isPriority.value,
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
    return Padding(
      padding: EdgeInsets.only(bottom: Get.mediaQuery.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
              autofocus: title == 'Tambah Tugas',
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
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: lightBlueBg,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryBlue, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          'Smart To-Do',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderGrey, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // --- Search Bar & Filters ---
          Container(
            color: Colors.white,
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
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  const Text(
                    'TUGAS AKTIF',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...controller.tasks
                      .where((t) => !t.isCompleted)
                      .map((task) => _buildTaskCard(task)),
                  
                  const SizedBox(height: 32),
                  _buildCompletedHeader(),
                  const SizedBox(height: 16),
                  ...controller.tasks
                      .where((t) => t.isCompleted)
                      .map((task) => _buildTaskCard(task)),
                ],
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
        border: Border.all(color: borderGrey),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Cari tugas...',
          hintStyle: TextStyle(color: textGrey, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: textGrey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Penting', 'Hari Ini', 'Besok'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          bool isActive = filter == 'Semua';
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              labelStyle: TextStyle(
                color: isActive ? Colors.white : textGrey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              selected: isActive,
              onSelected: (val) {},
              backgroundColor: const Color(0xFFF1F3F4),
              selectedColor: primaryBlue,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isActive ? primaryBlue : Colors.transparent),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                    color: task.isCompleted ? primaryBlue : borderGrey,
                    width: 2,
                  ),
                  color: task.isCompleted ? primaryBlue.withOpacity(0.1) : Colors.white,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: primaryBlue)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            
            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Badge Waktu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: task.isPriority ? const Color(0xFFFFEBEE) : const Color(0xFFF1F3F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              task.isPriority ? Icons.calendar_today : Icons.access_time,
                              size: 14,
                              color: task.isPriority ? Colors.red[700] : textGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.time,
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isPriority ? Colors.red[700] : textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Label opsional (misal kategori dari deskripsi)
                      if (task.description.isNotEmpty)
                        Expanded(
                          child: Text(
                            task.description,
                            style: const TextStyle(fontSize: 12, color: textGrey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: textGrey),
              onSelected: (val) {
                if (val == 'edit') _showEditTaskBottomSheet(task);
                if (val == 'delete') controller.deleteTask(task.id);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedHeader() {
    int count = controller.tasks.where((t) => t.isCompleted).length;
    return Row(
      children: [
        const Icon(Icons.keyboard_arrow_right, color: textGrey),
        const SizedBox(width: 8),
        Text(
          'SELESAI ($count)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textGrey,
          ),
        ),
      ],
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