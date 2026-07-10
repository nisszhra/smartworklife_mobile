import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_detail_controller.dart';
import '../../notulen/controllers/notulen_controller.dart';

class ChatDetailView extends GetView<ChatDetailController> {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF), // Light background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          if (controller.isSelectionMode) {
            return AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF005AB4)),
                onPressed: () => controller.clearSelection(),
              ),
              titleSpacing: 0,
              title: Text(
                '${controller.selectedMessageIds.length}',
                style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: const Color(0xFFE2E8F0), height: 1),
              ),
            );
          }
          
          return AppBar(
            backgroundColor: Colors.white, // White header
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF005AB4)),
              onPressed: () => Get.back(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF005AB4).withValues(alpha: 0.1),
                  backgroundImage: controller.avatarUrl.value != null ? NetworkImage(controller.avatarUrl.value!) : null,
                  child: controller.avatarUrl.value == null
                      ? Text(
                          controller.friendName.value.isNotEmpty ? controller.friendName.value[0].toUpperCase() : '?',
                          style: const TextStyle(color: Color(0xFF005AB4), fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.friendName.value,
                    style: const TextStyle(
                      color: Colors.black87, 
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: const Color(0xFFE2E8F0),
                height: 1,
              ),
            ),
          );
        }),
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: () {
                if (controller.messages.isEmpty) {
                  return Center(
                    child: Text('no_messages'.tr, style: const TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  controller: controller.scrollController,
                  reverse: true, // List dimulai dari bawah
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    // Karena reverse, index 0 adalah elemen terbawah layar (pesan terbaru).
                    // Namun 'messages' di controller tersusun urut kronologis [lama -> baru].
                    // Jadi kita harus membalik pengambilannya:
                    final reversedIndex = controller.messages.length - 1 - index;
                    final msg = controller.messages[reversedIndex];

                    // Check if we need to show date separator
                    bool showDate = false;
                    if (reversedIndex == 0) {
                      showDate = true;
                    } else {
                      final prevMsg = controller.messages[reversedIndex - 1];
                      if (msg.time.day != prevMsg.time.day || msg.time.month != prevMsg.time.month || msg.time.year != prevMsg.time.year) {
                        showDate = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(msg.time),
                        _buildChatBubble(msg),
                      ],
                    );
                  },
                );
              }()
            ),
            _buildInputArea(context),
          ],
        );
      }),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          formattedDate,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final timeStr = DateFormat('HH:mm').format(msg.time);
    final isSelected = controller.selectedMessageIds.contains(msg.id);
    final isMe = msg.isMe;
    final text = msg.deletedForEveryone ? "deleted_message".tr : msg.text;

    String displayText = text;
    String? sharedNotulenId;
    if (text.startsWith('📋 NOTULEN_SHARE:')) {
      final parts = text.split(' | ');
      if (parts.length >= 2) {
        sharedNotulenId = parts[0].replaceAll('📋 NOTULEN_SHARE:', '').trim();
        displayText = '📋 ${parts.sublist(1).join(' | ')}';
      }
    }

    return GestureDetector(
      onLongPress: () {
        controller.toggleSelection(msg.id);
      },
      onTap: () {
        if (controller.isSelectionMode) {
          controller.toggleSelection(msg.id);
        }
      },
      child: Container(
        color: isSelected ? const Color(0xFF005AB4).withValues(alpha: 0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            padding: EdgeInsets.only(
              left: 12, 
              right: msg.deletedForEveryone ? 12 : (isMe ? 8 : 12), 
              top: 10, 
              bottom: 8
            ),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF005AB4) : Colors.white,
              border: isMe ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMe ? 12 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 12),
              ),
              boxShadow: isMe || isSelected ? null : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            ),
            child: msg.deletedForEveryone ? 
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 14, color: isMe ? Colors.white70 : Colors.grey),
                  const SizedBox(width: 4),
                  Text(text, style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontStyle: FontStyle.italic, fontSize: 14)),
                ],
              ) :
              Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(displayText, isMe),
                  if (!isMe && displayText.startsWith('📋')) ...[
                    const SizedBox(height: 8),
                    Obx(() {
                      final isSaved = controller.savedMessageIds.contains(msg.id);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => _saveNotulenFromMessage(msg.id, displayText, sharedNotulenId, isSaved),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSaved ? Colors.green.withValues(alpha: 0.1) : const Color(0xFF005AB4).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSaved ? Colors.green.withValues(alpha: 0.3) : const Color(0xFF005AB4).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSaved ? Icons.check_circle_outline : Icons.bookmark_add_outlined, 
                                  size: 14, 
                                  color: isSaved ? Colors.green : const Color(0xFF005AB4)
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isSaved ? 'saved'.tr : 'save_to_archive'.tr, 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: isSaved ? Colors.green : const Color(0xFF005AB4), 
                                    fontWeight: FontWeight.w600
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(timeStr, style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10)),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.isRead ? Icons.done_all : Icons.check, 
                          size: 14, 
                          color: msg.isRead ? const Color(0xFF4ade80) : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(String text, bool isMe) {
    if (text.startsWith('📋')) {
      String title = "Notulen";
      String date = "";
      String duration = "";

      final lines = text.split('\n');
      if (lines.isNotEmpty) {
        title = lines[0].replaceAll('📋', '').replaceAll('*', '').trim();
      }
      if (lines.length > 1) {
        final parts = lines[1].split('⏱');
        date = parts[0].replaceAll('📅', '').trim();
        if (parts.length > 1) {
          duration = parts[1].trim();
        }
      }

      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.description_rounded,
                color: isMe ? Colors.white : const Color(0xFF005AB4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: isMe ? Colors.white70 : const Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(date, style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : const Color(0xFF64748B))),
                      const SizedBox(width: 10),
                      Icon(Icons.timer_outlined, size: 12, color: isMe ? Colors.white70 : const Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(duration, style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      text,
      style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
    );
  }

  void _saveNotulenFromMessage(String msgId, String messageText, String? sharedNotulenId, bool isAlreadySaved) {
    // Parse format: "📋 *Judul*\n📅 tanggal  ⏱ durasi"
    final lines = messageText.split('\n');
    // Ambil judul dari baris pertama: "📋 *Judul*" → "Judul"
    String title = lines.isNotEmpty ? lines[0] : 'Notulen dari Chat';
    title = title.replaceAll('📋', '').replaceAll('*', '').trim();
    if (title.isEmpty) title = 'Notulen dari Chat';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isAlreadySaved ? 'save_again_title'.tr : 'save_archive_title'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAlreadySaved
                  ? 'save_again_desc'.tr
                  : 'save_archive_desc'.tr,
              style: const TextStyle(color: Color(0xFF717785), fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: Color(0xFF717785))),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              try {
                final dio = controller.getDio();
                if (sharedNotulenId != null && sharedNotulenId.isNotEmpty) {
                  await dio.post('/notulens/shared/$sharedNotulenId/save');
                } else {
                  await dio.post('/notulens/save-from-chat', data: {
                    'title': title,
                    'transcript': messageText,
                    'meeting_date': DateTime.now().toUtc().toIso8601String(),
                  });
                }
                
                controller.markAsSaved(msgId);
                
                if (Get.isRegistered<NotulenController>()) {
                   Get.find<NotulenController>().fetchNotulen();
                }

                Get.snackbar(
                  'saved_success'.tr,
                  'saved_success_desc'.trParams({'title': title}),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF005AB4),
                  colorText: Colors.white,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  duration: const Duration(seconds: 3),
                );
              } catch (e) {
                Get.snackbar('share_fail'.tr, 'save_fail'.tr,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            icon: const Icon(Icons.bookmark_add),
            label: Text('save'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005AB4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'delete_msg_title'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteSelectedMessages('everyone');
                      },
                      child: Text('delete_for_everyone'.tr, style: const TextStyle(color: Colors.black87)),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteSelectedMessages('me');
                      },
                      child: Text('delete_for_me'.tr, style: const TextStyle(color: Colors.black87)),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.clearSelection();
                      },
                      child: Text('cancel'.tr, style: const TextStyle(color: Color(0xFF005AB4))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Tombol kirim notulen
            GestureDetector(
              onTap: () => _showNotulenPicker(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF005AB4).withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.description_outlined, color: Color(0xFF005AB4), size: 22),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8), // Light gray background for input
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.textController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'write_message'.tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF005AB4),
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotulenPicker(BuildContext context) {
    NotulenController? notulenCtrl;
    try {
      notulenCtrl = Get.find<NotulenController>();
    } catch (_) {
      notulenCtrl = null;
    }

    final archives = notulenCtrl?.archivedMeetings ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'choose_notulen'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const Divider(height: 1),
                if (archives.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open, size: 48, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 8),
                          Text('no_saved_notulen'.tr,
                              style: const TextStyle(color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: archives.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final a = archives[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            // Format pesan notulen yang akan dikirim (menyertakan ID)
                            final content =
                                '📋 NOTULEN_SHARE: ${a.id} | *${a.title}*\n'
                                '📅 ${a.date}  ⏱ ${a.duration}';
                            controller.sendNotulenMessage(content);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF005AB4).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.description_outlined,
                                      color: Color(0xFF005AB4), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF181C22)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        a.date,
                                        style: const TextStyle(
                                            color: Color(0xFF64748B), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
