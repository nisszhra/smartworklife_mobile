import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/data/models/notifikasi_model.dart';
import '../controllers/notifikasi_controller.dart';

class NotifikasiView extends GetView<NotifikasiController> {
  const NotifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF9F9FF);
    const Color primary = Color(0xFF005AB4);
    const Color textDark = Color(0xFF181C22);
    const Color textMuted = Color(0xFF717785);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'notifications_title'.tr,
          style: const TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox.shrink();
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: textDark),
              onSelected: (val) {
                if (val == 'read_all') {
                  controller.markAllAsRead();
                } else if (val == 'clear_all') {
                  controller.clearAll();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'read_all',
                  child: Row(
                    children: [
                      const Icon(Icons.done_all, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('mark_all_read'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('delete_all'.tr, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(primary),
          Expanded(
            child: Obx(() {
              final list = controller.filteredNotifications;

              if (list.isEmpty) {
                return _buildEmptyState(textDark, textMuted);
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: list.map((notif) {
                    return _buildDismissibleCard(context, notif, primary, textDark, textMuted);
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(Color primary) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildTabChip('filter_all'.tr, 'semua', primary),
              const SizedBox(width: 8),
              _buildTabChip('filter_health'.tr, 'health', primary),
              const SizedBox(width: 8),
              _buildTabChip('filter_productivity'.tr, 'productivity', primary),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabChip(String label, String value, Color primary) {
    final isSelected = controller.selectedCategory.value == value;
    return GestureDetector(
      onTap: () => controller.selectCategory(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.1) : const Color(0xFFF1F3F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? primary : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(
    BuildContext context,
    NotifikasiModel notif,
    Color primary,
    Color textDark,
    Color textMuted,
  ) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteNotification(notif.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 28),
      ),
      child: _buildNotificationCard(notif, primary, textDark, textMuted),
    );
  }

  Widget _buildNotificationCard(
    NotifikasiModel notif,
    Color primary,
    Color textDark,
    Color textMuted,
  ) {
    final Color categoryColor = notif.category == 'health' ? const Color(0xFF0EA5E9) : const Color(0xFF8B5CF6);
    final Color categoryBg = notif.category == 'health' ? const Color(0xFFE0F2FE) : const Color(0xFFF3E8FF);
    final IconData categoryIcon = notif.category == 'health' ? Icons.health_and_safety_outlined : Icons.work_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notif.isRead ? const Color(0xFFE2E8F0) : primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.onNotificationTap(notif),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: categoryBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                          ),
                          // Unread dot indicator
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif.body,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w500,
                          color: notif.isRead ? textMuted : const Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatTime(notif.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textDark, Color textMuted) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 44,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_notifications'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'no_notifications_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      if (diff.inMinutes <= 0) return 'just_now'.tr;
      return 'minutes_ago'.trParams({'count': diff.inMinutes.toString()});
    } else if (diff.inHours < 24) {
      return 'hours_ago'.trParams({'count': diff.inHours.toString()});
    } else if (diff.inDays == 1) {
      return 'yesterday'.tr;
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
