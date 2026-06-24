import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/notulen_controller.dart';
import 'notulen_detail_view.dart';

class NotulenArchiveView extends GetView<NotulenController> {
  const NotulenArchiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inSelection = controller.isSelectionMode.value;
      final selectedCount = controller.selectedIds.length;

      return Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        appBar: AppBar(
          title: inSelection
              ? Text(
                  '$selectedCount dipilih',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF005AB4),
                  ),
                )
              : const Text(
                  'Arsip Notulen',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF005AB4),
                  ),
                ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: inSelection
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF005AB4)),
                  onPressed: controller.exitSelectionMode,
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Color(0xFF005AB4)),
                  onPressed: () => Get.back(),
                ),
          actions: inSelection
              ? [
                  // Hapus yang dipilih
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFFDC2626)),
                    tooltip: 'Hapus dipilih',
                    onPressed: () => _confirmDeleteSelected(context),
                  ),
                  // Hapus semua
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined,
                        color: Color(0xFFDC2626)),
                    tooltip: 'Hapus semua',
                    onPressed: () => _confirmDeleteAll(context),
                  ),
                ]
              : [
                  // Tombol hapus semua saat tidak di selection mode
                  if (controller.archivedMeetings.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined,
                          color: Color(0xFFDC2626)),
                      tooltip: 'Hapus semua',
                      onPressed: () => _confirmDeleteAll(context),
                    ),
                ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE2E8F0), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (inSelection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          for (final m in controller.archivedMeetings) {
                            controller.selectedIds.add(m.id);
                          }
                          controller.isSelectionMode.value = true;
                        },
                        icon: const Icon(Icons.select_all, size: 18),
                        label: const Text('Pilih Semua'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF005AB4),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: controller.exitSelectionMode,
                        child: const Text('Batal',
                            style: TextStyle(color: Color(0xFF717785))),
                      ),
                    ],
                  ),
                )
              else ...[
                // const Text(
                //   'Recent Meetings',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xFF181C22),
                //   ),
                // ),
                const SizedBox(height: 8),
                const Text(
                  'Tekan lama untuk memilih beberapa notulen.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717785),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search meetings...',
                      hintStyle:
                          TextStyle(color: Color(0xFF5F6368), fontSize: 15),
                      prefixIcon:
                          Icon(Icons.search, color: Color(0xFF5F6368)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Obx(() => controller.archivedMeetings.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(Icons.folder_open,
                                size: 64, color: Color(0xFFCBD5E1)),
                            SizedBox(height: 16),
                            Text('Belum ada notulen tersimpan',
                                style: TextStyle(
                                    color: Color(0xFF94A3B8), fontSize: 15)),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: controller.archivedMeetings.length,
                      itemBuilder: (context, index) {
                        final archive = controller.archivedMeetings[index];
                        return _buildArchiveCard(context, archive);
                      },
                    )),
            ],
          ),
        ),
        // Bottom bar saat selection mode
        bottomNavigationBar: inSelection
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDeleteSelected(context),
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFFDC2626)),
                          label: Text(
                            'Hapus ($selectedCount)',
                            style:
                                const TextStyle(color: Color(0xFFDC2626)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFDC2626)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmDeleteAll(context),
                          icon: const Icon(Icons.delete_sweep_outlined),
                          label: const Text('Hapus Semua'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      );
    });
  }

  void _confirmDeleteSelected(BuildContext context) async {
    final count = controller.selectedIds.length;
    if (count == 0) return;
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus yang Dipilih?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '$count notulen yang dipilih akan dihapus permanen.',
          style: const TextStyle(color: Color(0xFF717785)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF717785))),
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
    if (confirm == true) controller.deleteSelected();
  }

  void _confirmDeleteAll(BuildContext context) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Notulen?',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
        content: const Text(
          'Semua notulen akan dihapus permanen dan tidak dapat dikembalikan!',
          style: TextStyle(color: Color(0xFF717785)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF717785))),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
    if (confirm == true) controller.deleteAll();
  }

  void _showCardOptions(BuildContext context, String archiveId, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Judul notulen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF181C22),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 1),
                // Opsi Share
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: Color(0xFF005AB4)),
                  title: const Text('Share', style: TextStyle(fontSize: 15)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    // Load data notulen lalu share sebagai teks
                    await controller.loadArchive(archiveId);
                    final shareTitle = controller.detailTitle.value;
                    final shareTranscript = controller.detailTranscript.value;
                    if (shareTitle.isNotEmpty || shareTranscript.isNotEmpty) {
                      final text = '📋 $shareTitle\n\n$shareTranscript';
                      await Clipboard.setData(ClipboardData(text: text));
                      Get.snackbar(
                        'Disalin!',
                        'Notulen telah disalin ke clipboard.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF005AB4),
                        colorText: Colors.white,
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                ),
                // Opsi Hapus
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                  title: const Text('Hapus', style: TextStyle(fontSize: 15, color: Color(0xFFDC2626))),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final confirm = await Get.dialog<bool>(
                      AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Hapus Notulen?',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Text(
                          'Notulen "$title" akan dihapus permanen.',
                          style: const TextStyle(color: Color(0xFF717785)),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) controller.deleteNotulen(archiveId);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchiveCard(BuildContext context, ArchivedMeeting archive) {
    return Obx(() {
      final isSelected = controller.selectedIds.contains(archive.id);
      final inSelection = controller.isSelectionMode.value;

      return GestureDetector(
        onLongPress: () => controller.enterSelectionMode(archive.id),
        onTap: () async {
          if (inSelection) {
            controller.toggleSelect(archive.id);
          } else {
            await controller.loadArchive(archive.id);
            Get.to(() => const NotulenDetailView());
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEFF6FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF005AB4)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      archive.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181C22),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Checkbox saat selection mode, hapus saat normal
                  if (inSelection)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        key: ValueKey(isSelected),
                        color: isSelected
                            ? const Color(0xFF005AB4)
                            : const Color(0xFFCBD5E1),
                        size: 22,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _showCardOptions(context, archive.id, archive.title),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.more_vert,
                            size: 20, color: Color(0xFF94A3B8)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                archive.date,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 11, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 3),
                  Text(archive.duration,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  archive.preview,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF414753),
                      height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
