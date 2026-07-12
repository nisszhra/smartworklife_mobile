import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/dio_service.dart';
import '../../../data/models/chat_model.dart';

class FriendRequestsController extends GetxController {
  final requests = <FriendshipResponse>[].obs;
  final isLoading = true.obs;
  
  final _dioService = Get.find<DioService>();
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final clearedIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadClearedIds();
    _fetchRequests();
  }

  Future<void> _loadClearedIds() async {
    final saved = await _storage.read(key: 'cleared_friend_requests');
    if (saved != null) {
      try {
        final List decoded = jsonDecode(saved);
        clearedIds.assignAll(decoded.cast<String>());
      } catch (_) {}
    }
  }

  Future<void> _saveClearedIds() async {
    await _storage.write(key: 'cleared_friend_requests', value: jsonEncode(clearedIds));
  }

  Future<void> _fetchRequests() async {
    isLoading.value = true;
    try {
      final response = await _dioService.client.get('/chat/friends');
      if (response.statusCode == 200) {
        final List data = response.data;
        final allFriendships = data.map((e) => FriendshipResponse.fromJson(e)).toList();
        
        final currentUser = Get.find<AuthService>().currentUser.value;
        if (currentUser == null) return;
        
        final incoming = allFriendships.where((f) {
           return f.addresseeId == currentUser.id && !clearedIds.contains(f.id);
        }).toList();
        
        requests.assignAll(incoming);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void accept(FriendshipResponse req) async {
    try {
      final response = await _dioService.client.put('/chat/friends/${req.id}', data: {
        'status': 'accepted'
      });
      if (response.statusCode == 200) {
        await _fetchRequests();
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().fetchFriends();
        }
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'sb_msg_8'.tr);
    }
  }

  void reject(FriendshipResponse req) async {
    try {
      final response = await _dioService.client.delete('/chat/friends/${req.id}');
      if (response.statusCode == 200) {
        requests.removeWhere((r) => r.id == req.id);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'sb_msg_9'.tr);
    }
  }

  void clearHistory() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Hapus Riwayat?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat konfirmasi pertemanan? (Permintaan yang masih menunggu tidak akan dihapus)'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final acceptedReqs = requests.where((req) => req.status == 'accepted').toList();
              for (var req in acceptedReqs) {
                clearedIds.add(req.id);
              }
              await _saveClearedIds();
              requests.removeWhere((req) => req.status == 'accepted');
              
              Get.back();
              Get.snackbar('success'.tr, 'sb_msg_10'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue[50],
                colorText: Colors.blue[900],
              );
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
