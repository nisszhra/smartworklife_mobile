import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_detail_controller.dart';

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
                  child: Text(
                    controller.friendName.value.isNotEmpty ? controller.friendName.value[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF005AB4), fontWeight: FontWeight.bold),
                  ),
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
                  return const Center(
                    child: Text('Belum ada pesan', style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];

                    // Check if we need to show date separator
                    bool showDate = false;
                    if (index == 0) {
                      showDate = true;
                    } else {
                      final prevMsg = controller.messages[index - 1];
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
            _buildInputArea(),
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
    final text = msg.deletedForEveryone ? "Anda menghapus pesan ini" : msg.text;

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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
                  ),
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
              const Text(
                'Hapus pesan?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      child: const Text('Hapus untuk semua orang', style: TextStyle(color: Colors.black87)),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteSelectedMessages('me');
                      },
                      child: const Text('Hapus untuk saya', style: TextStyle(color: Colors.black87)),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.clearSelection();
                      },
                      child: const Text('Batal', style: TextStyle(color: Color(0xFF005AB4))),
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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8), // Light gray background for input
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.textController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    hintStyle: TextStyle(color: Colors.grey),
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
}
