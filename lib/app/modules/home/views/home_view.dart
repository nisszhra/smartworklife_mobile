import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
              const SizedBox(height: 16),

              // Work-Life Balance Progress Bar Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Work-Life Balance',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final summary = controller.summary.value;
                        final workPct = summary?.workPercentage ?? 0.0;
                        final restPct = summary?.restPercentage ?? 0.0;
                        final exercisePct = summary?.exercisePercentage ?? 0.0;

                        // Pastikan persentase dikalikan 100 jika dari backend bukan 0-100,
                        // Namun backend kita sekarang me-return persen 0-100.
                        final workFlex = (workPct > 0) ? workPct.toInt() : 1; // 1 minimal untuk prevent render error
                        final restFlex = (restPct > 0) ? restPct.toInt() : 0;
                        final exerciseFlex = (exercisePct > 0) ? exercisePct.toInt() : 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                children: [
                                  if (workFlex > 0 || (restFlex == 0 && exerciseFlex == 0))
                                    Expanded(
                                      flex: workFlex,
                                      child: Container(height: 14, color: const Color(0xFF005AB4)),
                                    ),
                                  if (restFlex > 0)
                                    Expanded(
                                      flex: restFlex,
                                      child: Container(height: 14, color: const Color(0xFF8D6E63)),
                                    ),
                                  if (exerciseFlex > 0)
                                    Expanded(
                                      flex: exerciseFlex,
                                      child: Container(height: 14, color: const Color(0xFF4CAF50)),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF005AB4), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('Work (${workPct.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF8D6E63), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('Break (${restPct.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('Exercise (${exercisePct.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // My Points Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _showPointsInfoDialog(context),
                            child: Row(
                              children: [
                                Text('My Points', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                                const SizedBox(width: 4),
                                Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.8), size: 14),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final points = controller.summary.value?.points ?? 0;
                            // Format points with comma
                            final formattedPoints = NumberFormat('#,###').format(points);
                            return Text(
                              '$formattedPoints Points',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          }),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.LEADERBOARD),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A73E8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text(
                        'Lihat Leaderboard &\nRewards',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
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
              const SizedBox(height: 20),
              
              // Smart Insight
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
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
                            'Smart Insight',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Lihat Lainnya',
                              style: TextStyle(
                                color: Color(0xFF005AB4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Insight Card 1
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TRENDING',
                                  style: TextStyle(
                                    color: Color(0xFF005AB4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  '5 min read',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '5 Ways to Optimize Your Remote Workspace',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Discover how small changes to your lighting, ergonomics, and digital habits can boost your dai...',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Insight Card 2
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VIDEO HIGHLIGHT',
                              style: TextStyle(
                                color: Color(0xFFB9770E),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '5-Minute Desk Yoga for Neck Relief',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'YouTube • 5:15',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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

  void _showPointsInfoDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFF1A73E8)),
                  const SizedBox(width: 8),
                  const Text(
                    'Informasi Points',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Kumpulkan poin dari aktivitas produktif Anda! Berikut perhitungannya:',
                style: TextStyle(fontSize: 14, color: Color(0xFF414753)),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.timer, 'Fokus & Pomodoro', '1 Poin / sesi'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.accessibility, 'Exercise', '1 Poin / stretching'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.check_circle_outline, 'Tugas Selesai', '10 Poin / tugas'),
              const SizedBox(height: 8),
              const Text(
                'Presentase Work-Life Balance dihitung berdasarkan proporsi dari total Poin Fokus, Istirahat, dan Olahraga/Hidrasi Anda.',
                style: TextStyle(fontSize: 12, color: Color(0xFF717785), fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.emoji_events, color: Color(0xFF1D4ED8), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Leaderboard akan merangking pengguna berdasarkan poin per hari. Raih skor tertinggi Anda setiap harinya!',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF414753)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF181C22)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8)),
        ),
      ],
    );
  }
}
