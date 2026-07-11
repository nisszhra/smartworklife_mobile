import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final avatarUrl = RxnString();
  final messages = <ChatMessage>[].obs;
  final selectedMessageIds = <String>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final isLoading = true.obs;

  // Set untuk melacak ID pesan notulen yang sudah disimpan
  final savedMessageIds = <String>{}.obs;

  final _dioService = Get.find<DioService>();
  final _authService = Get.find<AuthService>();

  final _storage = const FlutterSecureStorage();
  final String _savedMsgKey = 'saved_notulen_msgs';

  StreamSubscription<QuerySnapshot>? _messageSubscription;

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
      avatarUrl.value = Get.arguments['avatarUrl'];
    } else if (Get.arguments != null) {
      friendName.value = Get.arguments.toString();
    }

    if (friendId.value.isNotEmpty) {
      isLoading.value = true;
      _loadCachedMessages();
      _loadMessages();
      _listenToFirestoreMessages();
    }
  }

  void _listenToFirestoreMessages() {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return;

    // Menentukan ID ruang obrolan (chat room).
    // Biasana kombinasi ID pengirim dan penerima yang diurutkan abjad agar konsisten
    final users = [currentUser.id, friendId.value];
    users.sort();
    final chatRoomId = users.join('_');

    _messageSubscription?.cancel();
    _messageSubscription = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final unreadIds = <String>[];

            for (var change in snapshot.docChanges) {
              final data = change.doc.data();
              if (data == null) continue;

              final senderId = data['sender_id'];
              final msg = ChatMessage(
                id: change.doc.id,
                text: data['content'] ?? '',
                isMe: senderId == currentUser.id,
                time: data['timestamp'] != null
                    ? (data['timestamp'] as Timestamp).toDate()
                    : DateTime.now(),
                isRead: data['is_read'] ?? false,
                deletedForEveryone: data['deleted_for_everyone'] ?? false,
              );

              if (!msg.isMe && !msg.isRead && !msg.deletedForEveryone) {
                unreadIds.add(msg.id);
              }

              final existingIndex = messages.indexWhere((m) => m.id == msg.id);
              if (change.type == DocumentChangeType.added ||
                  change.type == DocumentChangeType.modified) {
                if (existingIndex == -1) {
                  messages.add(msg);
                } else {
                  messages[existingIndex] = msg;
                }
              } else if (change.type == DocumentChangeType.removed) {
                messages.removeWhere((m) => m.id == msg.id);
              }
            }

            if (unreadIds.isNotEmpty) {
              _markAsRead(unreadIds);
            }

            // Pastikan diurutkan descending (paling baru di awal list, karena reverse: true)
            messages.sort((a, b) => a.time.compareTo(b.time));

            if (messages.isNotEmpty) {
              _saveCachedMessages(messages);
            }
          },
          onError: (error) {
            debugPrint('Firestore Error: $error');
          },
        );
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

  Future<void> _loadCachedMessages() async {
    try {
      final key = 'chat_cache_${friendId.value}';
      final data = await _storage.read(key: key);
      if (data != null) {
        final List list = jsonDecode(data);
        final currentUser = _authService.currentUser.value;
        if (currentUser != null) {
          final cached = list
              .map(
                (e) => ChatMessage(
                  id: e['id'],
                  text: e['text'],
                  isMe: e['isMe'],
                  time: DateTime.parse(e['time']).toLocal(),
                  isRead: e['isRead'] ?? false,
                  deletedForEveryone: e['deletedForEveryone'] ?? false,
                ),
              )
              .toList();

          cached.sort((a, b) => a.time.compareTo(b.time));
          messages.assignAll(cached);
          isLoading.value = false;
        }
      }
    } catch (e) {
      debugPrint("Cache error: $e");
    }
  }

  Future<void> _saveCachedMessages(List<ChatMessage> msgs) async {
    try {
      final key = 'chat_cache_${friendId.value}';
      final list = msgs
          .map(
            (e) => {
              'id': e.id,
              'text': e.text,
              'isMe': e.isMe,
              'time': e.time.toUtc().toIso8601String(),
              'isRead': e.isRead,
              'deletedForEveryone': e.deletedForEveryone,
            },
          )
          .toList();
      await _storage.write(key: key, value: jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _dioService.client.get(
        '/chat/messages/${friendId.value}',
      );
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

        // Urutkan dari yang terbaru ke terlama (descending)
        newMessages.sort((a, b) => a.time.compareTo(b.time));

        // Gabungkan dengan pesan dari Firestore jika ada yang belum ter-fetch dari API
        final Map<String, ChatMessage> messageMap = {
          for (var m in messages) m.id: m,
        };
        for (var m in newMessages) {
          messageMap[m.id] = m;
        }

        final mergedMessages = messageMap.values.toList();
        mergedMessages.sort((a, b) => a.time.compareTo(b.time));

        messages.assignAll(mergedMessages);
        _saveCachedMessages(mergedMessages);
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint("Load messages error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _markAsRead(List<String> ids) async {
    try {
      await _dioService.client.put(
        '/chat/messages/read',
        data: {'message_ids': ids},
      );
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
      await _dioService.client.delete(
        '/chat/messages',
        data: {'message_ids': idsToDelete, 'delete_type': deleteType},
      );
      _loadMessages();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus pesan');
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || friendId.value.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    messages.add(
      ChatMessage(id: tempId, text: text, isMe: true, time: DateTime.now()),
    );
    textController.clear();
    _scrollToBottom();

    try {
      final response = await _dioService.client.post(
        '/chat/messages',
        data: {'receiver_id': friendId.value, 'content': text},
      );
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
    messages.add(
      ChatMessage(id: tempId, text: content, isMe: true, time: DateTime.now()),
    );
    _scrollToBottom();

    try {
      await _dioService.client.post(
        '/chat/messages',
        data: {'receiver_id': friendId.value, 'content': content},
      );
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
    _messageSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
