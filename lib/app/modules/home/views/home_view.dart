import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/app_translations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/todo_model.dart';
import '../../../routes/app_pages.dart';
import '../../todolist/controllers/todolist_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String _formatDuration(int seconds) {
    if (seconds < 60 && seconds > 0) return '${seconds}s';
    final totalMinutes = seconds ~/ 60;
    if (totalMinutes < 60) return '${totalMinutes}m';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'good_morning'.tr;
    if (hour >= 12 && hour < 17) return 'good_afternoon'.tr;
    if (hour >= 17 && hour < 20) return 'good_evening'.tr;
    return 'good_night'.tr;
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
              Obx(
                () => Text(
                  '${_getGreeting()}, ${Get.find<AuthService>().currentUser.value?.fullName ?? 'User'} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'productivity_overview'.tr,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Productivity Overview Cards
              Obx(() {
                if (controller.isLoading.value &&
                    controller.summary.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final summary = controller.summary.value;
                final focusTime = summary?.focusTime ?? 0;
                final breakTime = summary?.breakTime ?? 0;
                final tasksDoneRate = summary?.tasksDoneRate ?? 0.0;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'focus_time'.tr,
                        _formatDuration(focusTime),
                        Icons.timer,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'break_time'.tr,
                        _formatDuration(breakTime),
                        Icons.coffee,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'tasks_done'.tr,
                        '${tasksDoneRate.toInt()}%',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final summary = controller.summary.value;
                        final workPct = summary?.workPercentage ?? 0.0;
                        final restPct = summary?.restPercentage ?? 0.0;
                        final exercisePct = summary?.exercisePercentage ?? 0.0;

                        // Pastikan persentase dikalikan 100 jika dari backend bukan 0-100,
                        // Namun backend kita sekarang me-return persen 0-100.
                        final workFlex = (workPct > 0)
                            ? workPct.toInt()
                            : 1; // 1 minimal untuk prevent render error
                        final restFlex = (restPct > 0) ? restPct.toInt() : 0;
                        final exerciseFlex = (exercisePct > 0)
                            ? exercisePct.toInt()
                            : 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                children: [
                                  if (workFlex > 0 ||
                                      (restFlex == 0 && exerciseFlex == 0))
                                    Expanded(
                                      flex: workFlex,
                                      child: Container(
                                        height: 14,
                                        color: const Color(0xFF005AB4),
                                      ),
                                    ),
                                  if (restFlex > 0)
                                    Expanded(
                                      flex: restFlex,
                                      child: Container(
                                        height: 14,
                                        color: const Color(0xFF8D6E63),
                                      ),
                                    ),
                                  if (exerciseFlex > 0)
                                    Expanded(
                                      flex: exerciseFlex,
                                      child: Container(
                                        height: 14,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF005AB4),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${'work'.tr} (${workPct.toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF8D6E63),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${'break'.tr} (${restPct.toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${'exercise'.tr} (${exercisePct.toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
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
                                Flexible(
                                  child: Text(
                                    'my_points'.tr,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            final points =
                                controller.summary.value?.points ?? 0;
                            // Format points with comma
                            final formattedPoints = NumberFormat(
                              '#,###',
                            ).format(points);
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$formattedPoints ${'points'.tr}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.LEADERBOARD),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A73E8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'view_leaderboard'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(Routes.TODOLIST),
                            child: Text(
                              'see_all'.tr,
                              style: const TextStyle(
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
                        final activeTasks = todolistController.tasks
                            .where((t) {
                              if (t.isCompleted) return false;

                              final now = DateTime.now();
                              if (controller.selectedFilter.value ==
                                  'filter_important'.tr) {
                                return t.isPriority;
                              } else if (controller.selectedFilter.value ==
                                  'filter_today'.tr) {
                                return t.deadline != null &&
                                    t.deadline!.year == now.year &&
                                    t.deadline!.month == now.month &&
                                    t.deadline!.day == now.day;
                              } else if (controller.selectedFilter.value ==
                                  'filter_tomorrow'.tr) {
                                final tomorrow = now.add(
                                  const Duration(days: 1),
                                );
                                return t.deadline != null &&
                                    t.deadline!.year == tomorrow.year &&
                                    t.deadline!.month == tomorrow.month &&
                                    t.deadline!.day == tomorrow.day;
                              } else if (controller.selectedFilter.value ==
                                  'filter_overdue'.tr) {
                                return t.isOverdue;
                              }
                              return true;
                            })
                            .take(3)
                            .toList();

                        if (activeTasks.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'no_active_tasks'.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
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
                                  Divider(
                                    color: Colors.grey.withOpacity(0.1),
                                    height: 1,
                                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Smart Insight',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(Routes.BERITA),
                            child: Text(
                              'see_more'.tr,
                              style: const TextStyle(
                                color: Color(0xFF005AB4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Obx(() {
                        if (controller.listBerita.isNotEmpty) {
                          final lastUpdate =
                              controller.listBerita.first.scrapedAt ?? '';
                          if (lastUpdate.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'updated'.trParams({'time': AppTranslations.translateIndonesianDate(lastUpdate)}),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      }),
                      const SizedBox(height: 8),
                      // List Berita
                      Obx(() {
                        if (controller.isBeritaLoading.value &&
                            controller.listBerita.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (controller.listBerita.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text("no_news".tr),
                            ),
                          );
                        }

                        return Column(
                          children: controller.listBerita.take(3).map((berita) {
                            // Waktu publikasi berita
                            String publishTime = berita.publishedDate ?? '';
                            if (publishTime.isEmpty) publishTime = 'just_now'.tr;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              ('cat_${(berita.keyword ?? 'TRENDING').toLowerCase()}'.tr)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFF005AB4),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (berita.source == 'YouTube')
                                                  ? Colors.red[50]
                                                  : Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color:
                                                    (berita.source == 'YouTube')
                                                    ? Colors.red[200]!
                                                    : Colors.blue[200]!,
                                              ),
                                            ),
                                            child: Text(
                                              berita.source ?? 'Web',
                                              style: TextStyle(
                                                color:
                                                    (berita.source == 'YouTube')
                                                    ? Colors.red[700]
                                                    : Colors.blue[700],
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppTranslations.translateIndonesianDate(publishTime),
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    berita.title ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      if (berita.link != null &&
                                          berita.link!.isNotEmpty) {
                                        final url = Uri.parse(berita.link!);
                                        try {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        } catch (e) {
                                          debugPrint("Could not launch $url");
                                        }
                                      }
                                    },
                                    child: Text(
                                      'read_more'.tr,
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
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

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'filter_important'.tr,
      'filter_today'.tr,
      'filter_tomorrow'.tr,
      'filter_overdue'.tr,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
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
                          color: isActive
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFF5F6368),
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
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
        ),
      ),
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
                        : (task.isOverdue
                              ? Colors.red
                              : const Color(0xFFE0E0E0)),
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? const Color(0xFF1A73E8).withOpacity(0.1)
                      : (task.isOverdue ? Colors.red[50] : Colors.white),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFF1A73E8),
                      )
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
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
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
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'overdue_label'.tr,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB71C1C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (task.isExtended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'extended_label'.tr,
                              style: const TextStyle(
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
                              fontSize: 12,
                              color: Color(0xFF5F6368),
                            ),
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
                if (val == 'edit')
                  _showEditTaskBottomSheet(task, todolistController);
                if (val == 'delete') todolistController.deleteTask(task.id);
                if (val == 'extend')
                  _showExtendDeadlineBottomSheet(task, todolistController);
              },
              itemBuilder: (context) => [
                if (task.isOverdue)
                  PopupMenuItem(
                    value: 'extend',
                    child: Row(
                      children: [
                        const Icon(Icons.history, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('extend_deadline'.tr),
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

  void _showEditTaskBottomSheet(
    TodoModel task,
    TodolistController todolistController,
  ) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    final initDate = task.deadline?.toLocal() ?? DateTime.now();
    final selectedDate = initDate.obs;
    final selectedTime = TimeOfDay(
      hour: initDate.hour,
      minute: initDate.minute,
    ).obs;
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
          final taskDateStr =
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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

  void _showExtendDeadlineBottomSheet(
    TodoModel task,
    TodolistController todolistController,
  ) {
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
                    child: Obx(
                      () => GestureDetector(
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
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
                      ),
                    ),
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
                    final deadline = DateTime(
                      d.year,
                      d.month,
                      d.day,
                      t.hour,
                      t.minute,
                    );
                    await todolistController.extendOverdueTask(
                      task: task,
                      newDeadline: deadline,
                    );
                    Get.back();
                    Get.snackbar('success'.tr, 'sb_msg_11'.tr,
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
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Judul Tugas'),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: _getInputDecoration(
                    'Apa yang ingin Anda kerjakan?',
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Deskripsi'),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: _getInputDecoration(
                    'Tambahkan catatan detail...',
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Tenggat Waktu'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: Get.context!,
                              initialDate: selectedDate.value,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) selectedDate.value = picked;
                          },
                          child: _buildDateTimePickerBox(
                            Icons.calendar_today,
                            '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => GestureDetector(
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
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPriority.value
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPriority.value
                            ? const Color(0xFFFFCDD2)
                            : Colors.grey[200]!,
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
                              color: isPriority.value
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontWeight: isPriority.value
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
                  ),
                ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                  Text(
                    'points_info'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'points_info_desc'.tr,
                style: const TextStyle(fontSize: 14, color: Color(0xFF414753)),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.timer,
                'focus_pomodoro'.tr,
                'points_per_cycle'.tr,
                'pomodoro_cycle_desc'.tr,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.accessibility,
                'smart_stretching'.tr,
                'max_points_per_day'.tr,
                'stretching_points_desc'.tr,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.check_circle_outline,
                'tasks_done'.tr,
                'points_per_task'.tr,
              ),
              const SizedBox(height: 12),
              Text(
                'wlb_calculation_desc'.tr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF717785),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF1D4ED8),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'leaderboard_info_desc'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w500,
                        ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('got_it'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, [
    String? subtitle,
  ]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF414753)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181C22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717785),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
