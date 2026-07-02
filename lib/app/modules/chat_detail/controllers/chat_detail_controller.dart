import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/services/auth_service.dart';
import '../../chat/controllers/chat_controller.dart';

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
  
  // Set untuk melacak ID pesan notulen yang sudah disimpan
  final savedMessageIds = <String>{}.obs;

  final _dioService = Get.find<DioService>();
  final _authService = Get.find<AuthService>();
  
  final _storage = const FlutterSecureStorage();
  final String _savedMsgKey = 'saved_notulen_msgs';

  WebSocketChannel? _wsChannel;
  
  bool get isSelectionMode => selectedMessageIds.isNotEmpty;

  /// Ekspos Dio client untuk digunakan di View layer
  dynamic getDio() => _dioService.client;

  void markAsSaved(String msgId) async {
    savedMessageIds.add(msgId);
    try {
      final listStr = jsonEncode(savedMessageIds.toList());
      await _storage.write(key: _savedMsgKey, value: listStr);
    } catch (e) {
      debugPrint("Error saving to storage: $e");
    }
  }

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
    _loadSavedMessages();
    
    if (Get.arguments != null && Get.arguments is Map) {
      friendName.value = Get.arguments['friendName'] ?? 'User';
      friendId.value = Get.arguments['friendId'] ?? '';
    } else if (Get.arguments != null) {
      friendName.value = Get.arguments.toString();
    }
    
    if (friendId.value.isNotEmpty) {
      _loadMessages();
      _connectWebSocket();
    }
  }

  void _connectWebSocket() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      String baseUrl = _dioService.client.options.baseUrl;
      String wsUrl = baseUrl.replaceFirst('http', 'ws');
      // e.g. https://... -> wss://...
      
      final uri = Uri.parse('$wsUrl/chat/ws?token=$token');
      
      _wsChannel = WebSocketChannel.connect(uri);
      
      _wsChannel!.stream.listen(
        (data) {
          final decoded = jsonDecode(data);
          // Pastikan pesan yang masuk berasal dari teman chat kita saat ini
          // atau pesan yang baru kita kirim sendiri
          if (decoded['sender_id'] == friendId.value || decoded['receiver_id'] == friendId.value) {
            final newMsg = ChatMessage(
              id: decoded['id'],
              text: decoded['content'],
              isMe: decoded['sender_id'] != friendId.value,
              time: DateTime.parse(decoded['created_at']).toLocal(),
              isRead: decoded['is_read'] ?? false,
              deletedForEveryone: decoded['deleted_for_everyone'] ?? false,
            );
            
            // Cek apakah pesan sudah ada (menghindari duplikasi saat mengirim)
            final index = messages.indexWhere((m) => m.id == newMsg.id);
            if (index == -1) {
              messages.add(newMsg);
              _scrollToBottom();
              
              if (!newMsg.isMe) {
                 _markAsRead([newMsg.id]);
              }
            }
          }
        },
        onError: (error) {
          debugPrint('WebSocket Error: $error');
        },
        onDone: () {
          debugPrint('WebSocket Disconnected');
          // Opsional: reconnect otomatis
        },
      );
    } catch (e) {
      debugPrint('WebSocket connect error: $e');
    }
  }

  Future<void> _loadSavedMessages() async {
    try {
      final data = await _storage.read(key: _savedMsgKey);
      if (data != null) {
        final List<dynamic> list = jsonDecode(data);
        savedMessageIds.addAll(list.cast<String>());
      }
    } catch (e) {
      debugPrint("Error loading from storage: $e");
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
            time: DateTime.parse(e['created_at']).toLocal(),
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
      // Refresh chat list to update the unread badge
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().fetchFriends(silent: true);
      }
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
      final response = await _dioService.client.post('/chat/messages', data: {
        'receiver_id': friendId.value,
        'content': text,
      });
      // Sukses dikirim via API
      // Backend akan men-trigger WebSocket, tetapi kita sudah handle tempId di atas
      // Atau biarkan WebSocket yang menangkap pesan resminya, lalu hapus pesan temp.
      
      final realMsgData = response.data;
      
      // Update tempId dengan ID asli dari backend
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = ChatMessage(
          id: realMsgData['id'],
          text: realMsgData['content'],
          isMe: true,
          time: DateTime.parse(realMsgData['created_at']).toLocal(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
      messages.removeWhere((m) => m.id == tempId);
    }
  }

  Future<void> sendNotulenMessage(String content) async {
    if (content.isEmpty || friendId.value.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.add(ChatMessage(
      id: tempId,
      text: content,
      isMe: true,
      time: DateTime.now(),
    ));
    _scrollToBottom();

    try {
      await _dioService.client.post('/chat/messages', data: {
        'receiver_id': friendId.value,
        'content': content,
      });
      _loadMessages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim notulen');
      messages.removeWhere((m) => m.id == tempId);
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          0.0, // Karena ListView sekarang di-reverse, 0.0 adalah posisi paling bawah
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void onClose() {
    _wsChannel?.sink.close();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
