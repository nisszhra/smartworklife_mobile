import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
import '../controllers/chat_controller.dart';
import 'add_friend_view.dart';
import '../../../data/models/chat_model.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        title: Text(
          'chats_title'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF005AB4),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF005AB4)),
            onPressed: () {
              Get.toNamed(Routes.FRIEND_REQUESTS);
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.search, color: Color(0xFF005AB4)),
          //   onPressed: () {
          //     // Search action
          //   },
          // ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF005AB4)));
        }
        if (controller.chatList.isEmpty) {
          return Center(
            child: Text(
              'no_chats'.tr,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.chatList.length,
          itemBuilder: (context, index) {
            final item = controller.chatList[index];
            final name = item.friendName;
            final isPending = item.status == 'pending';
            final lastMsg = item.lastMessage;
            final unreadCount = item.unreadCount;
            final timeStr = item.lastMessageTime != null ? DateFormat('HH:mm').format(item.lastMessageTime!) : '';

            String subtitleText = 'start_new_chat'.tr;
            if (isPending) {
              subtitleText = 'waiting_friend_confirmation'.tr;
            } else if (lastMsg != null) {
              if (lastMsg.startsWith('📋 NOTULEN_SHARE:')) {
                final parts = lastMsg.split(' | ');
                if (parts.length >= 2) {
                  final titleLine = parts[1].split('\n')[0].replaceAll('*', '').trim();
                  subtitleText = '📋 $titleLine';
                } else {
                  subtitleText = 'sending_minutes'.tr;
                }
              } else {
                subtitleText = lastMsg;
              }
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Slidable(
                  key: ValueKey(item.friendId),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _showDeleteDialog(context, item);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'delete'.tr,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF005AB4).withValues(alpha: 0.1),
                        backgroundImage: item.avatarUrl != null ? NetworkImage(item.avatarUrl!) : null,
                        child: item.avatarUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Color(0xFF005AB4), fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        subtitleText,
                        style: TextStyle(
                          color: isPending ? Colors.orange : (unreadCount > 0 ? Colors.black87 : Colors.grey),
                          fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                          fontWeight: (unreadCount > 0 && !isPending) ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isPending && timeStr.isNotEmpty)
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    color: unreadCount > 0 ? const Color(0xFF005AB4) : Colors.grey, 
                                    fontSize: 12, 
                                    fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal
                                  ),
                                ),
                              const SizedBox(height: 4),
                              if (unreadCount > 0 && !isPending)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF005AB4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: isPending ? null : () {
                        Get.toNamed(Routes.CHAT_DETAIL, arguments: {
                          'friendName': name,
                          'friendId': item.friendId,
                          'avatarUrl': item.avatarUrl,
                        })?.then((_) {
                          controller.fetchFriends(silent: true);
                        });
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddFriendView());
        },
        backgroundColor: const Color(0xFF005AB4),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatListItem item) {
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
                'delete_chat_confirm'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('cancel'.tr, style: const TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteChatHistory(item);
                      },
                      child: Text('delete'.tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
}
