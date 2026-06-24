import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/friend_requests_controller.dart';

class FriendRequestsView extends GetView<FriendRequestsController> {
  const FriendRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF005AB4)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Konfirmasi Pertemanan',
          style: TextStyle(
            color: Color(0xFF005AB4),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            if (!controller.requests.any((req) => req.status == 'accepted')) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.grey),
              tooltip: 'Hapus Riwayat',
              onPressed: () => controller.clearHistory(),
            );
          }),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Obx(() {
        if (controller.requests.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada permintaan baru',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final req = controller.requests[index];
            final reqName = req.requester?.fullName ?? req.requester?.email ?? 'Unknown';
            return Card(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF005AB4).withValues(alpha: 0.1),
                      child: Text(
                        reqName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF005AB4), 
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reqName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            req.status == 'accepted' ? 'Anda sekarang rekan.' : 'Ingin terhubung dengan Anda',
                            style: TextStyle(
                              color: req.status == 'accepted' ? const Color(0xFF005AB4) : Colors.grey,
                              fontSize: 13,
                              fontWeight: req.status == 'accepted' ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (req.status != 'accepted')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withValues(alpha: 0.1),
                            ),
                            onPressed: () => controller.reject(req),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check, color: Color(0xFF005AB4)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF005AB4).withValues(alpha: 0.1),
                            ),
                            onPressed: () => controller.accept(req),
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.handshake, color: Color(0xFF005AB4)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
