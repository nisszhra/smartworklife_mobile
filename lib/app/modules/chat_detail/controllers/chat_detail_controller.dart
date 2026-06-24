import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final bool isRead;
  final bool deletedForEveryone;

  ChatMessage({
    required this.id,
    required this.text, 
    required this.isMe, 
    required this.time,
    this.isRead = false,
    this.deletedForEveryone = false,
  });
}

class ChatDetailController extends GetxController {
  final friendName = ''.obs;
  final friendId = ''.obs;
  final messages = <ChatMessage>[].obs;
  final selectedMessageIds = <String>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  
  final _dioService = Get.find<DioService>();
  final _authService = Get.find<AuthService>();
  
  Timer? _pollingTimer;

  bool get isSelectionMode => selectedMessageIds.isNotEmpty;

  void toggleSelection(String id) {
    if (selectedMessageIds.contains(id)) {
      selectedMessageIds.remove(id);
    } else {
      selectedMessageIds.add(id);
    }
  }

  void clearSelection() {
    selectedMessageIds.clear();
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      friendName.value = Get.arguments['friendName'] ?? 'User';
      friendId.value = Get.arguments['friendId'] ?? '';
    } else if (Get.arguments != null) {
      friendName.value = Get.arguments.toString();
    }
    
    if (friendId.value.isNotEmpty) {
      _loadMessages();
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _loadMessages();
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _dioService.client.get('/chat/messages/${friendId.value}');
      if (response.statusCode == 200) {
        final List data = response.data;
        final currentUser = _authService.currentUser.value;
        if (currentUser == null) return;
        
        final newMessages = data.map((e) {
          final senderId = e['sender_id'];
          return ChatMessage(
            id: e['id'],
            text: e['content'],
            isMe: senderId == currentUser.id,
            time: DateTime.parse(e['created_at']),
            isRead: e['is_read'] ?? false,
            deletedForEveryone: e['deleted_for_everyone'] ?? false,
          );
        }).toList();
        
        final unreadIds = newMessages
            .where((m) => !m.isMe && !m.isRead && !m.deletedForEveryone)
            .map((m) => m.id)
            .toList();

        if (unreadIds.isNotEmpty) {
          _markAsRead(unreadIds);
        }

        if (newMessages.length > messages.length) {
          messages.assignAll(newMessages);
          _scrollToBottom();
        } else {
          messages.assignAll(newMessages);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _markAsRead(List<String> ids) async {
    try {
      await _dioService.client.put('/chat/messages/read', data: {
        'message_ids': ids
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteSelectedMessages(String deleteType) async {
    if (selectedMessageIds.isEmpty) return;
    
    final idsToDelete = List<String>.from(selectedMessageIds);
    clearSelection();

    try {
      await _dioService.client.delete('/chat/messages', data: {
        'message_ids': idsToDelete,
        'delete_type': deleteType
      });
      _loadMessages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus pesan');
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || friendId.value.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.add(ChatMessage(
      id: tempId,
      text: text,
      isMe: true,
      time: DateTime.now(),
    ));
    textController.clear();
    _scrollToBottom();

    try {
      await _dioService.client.post('/chat/messages', data: {
        'receiver_id': friendId.value,
        'content': text,
      });
      _loadMessages();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
      messages.removeWhere((m) => m.id == tempId);
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
