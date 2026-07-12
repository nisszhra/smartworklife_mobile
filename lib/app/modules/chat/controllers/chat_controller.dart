import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/services/notification_service.dart';
import '../../../routes/app_pages.dart';

class ChatController extends GetxController {
  final chatList = <ChatListItem>[].obs;
  final friendNameController = TextEditingController();
  final isSearching = false.obs;
  final isLoading = true.obs;

  final _dioService = Get.find<DioService>();

  Timer? _pollingTimer;
  final _previousUnreadCounts = <String, int>{};

  /// Total pesan belum dibaca dari semua percakapan
  int get totalUnreadCount => chatList.fold(0, (sum, item) => sum + (item.unreadCount ?? 0));

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
    startPolling();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchFriends(silent: true);
    });
  }

  Future<void> fetchFriends({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final response = await _dioService.client.get('/chat/friends');
      if (response.statusCode == 200) {
        final List data = response.data;
        final friendships = data.map((e) => FriendshipResponse.fromJson(e)).toList();
        
        final currentUser = Get.find<AuthService>().currentUser.value;
        if (currentUser == null) return;

        final items = friendships.where((f) => f.status == 'accepted' || (f.status == 'pending' && f.requesterId == currentUser.id)).map((f) {
           final isRequester = f.requesterId == currentUser.id;
           final otherUser = isRequester ? f.addressee : f.requester;
           return ChatListItem(
             friendshipId: f.id,
             friendId: otherUser?.id ?? '',
             friendName: otherUser?.fullName ?? otherUser?.email ?? 'Unknown',
             status: f.status,
             isRequester: isRequester,
             lastMessage: f.lastMessage,
             lastMessageTime: f.lastMessageTime,
             lastMessageSenderId: f.lastMessageSenderId,
             lastMessageIsRead: f.lastMessageIsRead,
             unreadCount: f.unreadCount,
             avatarUrl: otherUser?.avatarUrl,
           );
        }).toList();
        
        // Sort by last message time (descending)
        items.sort((a, b) {
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });
            
        if (silent && Get.isRegistered<NotificationService>()) {
          final currentRoute = Get.currentRoute;
          final currentArgs = Get.arguments as Map<String, dynamic>?;
          final currentFriendId = currentArgs?['friendId'] as String?;

          for (final item in items) {
            final oldUnread = _previousUnreadCounts[item.friendId] ?? 0;
            final newUnread = item.unreadCount ?? 0;

            if (newUnread > oldUnread) {
              final isViewingThisChat = (currentRoute == Routes.CHAT_DETAIL && currentFriendId == item.friendId);
              final isAppForeground = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
              
              if (!isViewingThisChat && isAppForeground) {
                Get.find<NotificationService>().showChatNotification(
                  friendId: item.friendId,
                  friendName: item.friendName,
                  message: item.lastMessage ?? 'Mengirim pesan baru',
                );
              }
            }
            _previousUnreadCounts[item.friendId] = newUnread;
          }
        } else {
          for (final item in items) {
            _previousUnreadCounts[item.friendId] = item.unreadCount ?? 0;
          }
        }

        chatList.assignAll(items);
      }
    } catch (e) {
      //
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> deleteChatHistory(ChatListItem item) async {
    try {
      await _dioService.client.delete('/chat/messages/all/${item.friendId}');
      fetchFriends();
    } catch (e) {
      Get.snackbar('error'.tr, 'sb_msg_0'.tr);
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    friendNameController.dispose();
    super.onClose();
  }

  final searchResult = Rxn<UserPublic>();
  final searchError = ''.obs;

  Future<void> searchUser(String name) async {
    isSearching.value = true;
    searchResult.value = null; // reset
    searchError.value = '';
    
    try {
      final response = await _dioService.client.get('/chat/users/search', queryParameters: {'q': name});
      if (response.statusCode == 200) {
        final List data = response.data;
        if (data.isNotEmpty) {
           searchResult.value = UserPublic.fromJson(data.first);
        } else {
           searchError.value = 'User dengan akun "$name" tidak terdaftar.';
        }
      }
    } catch (e) {
        searchError.value = 'Terjadi kesalahan saat mencari user.';
    } finally {
        isSearching.value = false;
    }
  }

  Future<void> addFriendFromSearch() async {
    final targetUser = searchResult.value;
    if (targetUser == null) return;
    
    try {
      final response = await _dioService.client.post('/chat/friends/request', data: {
        'addressee_id': targetUser.id
      });
      
        if (response.statusCode == 200 || response.statusCode == 201) {
         Get.snackbar('success'.tr, 'sb_msg_1'.tr + ' ${targetUser.fullName ?? targetUser.email}.',
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green[50],
          colorText: Colors.green[900],
        );
        fetchFriends(); // Refresh list to show pending
      }
    } on DioException catch (e) {
      Get.snackbar(
        'Gagal', 
        e.response?.data['detail'] ?? 'Permintaan sudah dikirim atau gagal.',
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[900],
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'sb_msg_2'.tr,
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[900],
      );
    }
    
    searchResult.value = null;
    friendNameController.clear();
    Get.back(); // close dialog
  }

  void deleteFriend(ChatListItem item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Hapus Obrolan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus obrolan dengan ${item.friendName}? Riwayat pesan juga akan terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _dioService.client.delete('/chat/friends/${item.friendshipId}');
                chatList.removeWhere((i) => i.friendshipId == item.friendshipId);
                Get.back();
                Get.snackbar('success'.tr, 'sb_msg_3'.tr + ' ${item.friendName} telah dihapus.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue[50],
                  colorText: Colors.blue[900],
                );
              } catch (e) {
                Get.snackbar('error'.tr, 'sb_msg_4'.tr);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
