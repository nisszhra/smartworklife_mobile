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
        ],
      ),
    );
  }
}
