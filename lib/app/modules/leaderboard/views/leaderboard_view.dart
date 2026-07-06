import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/leaderboard_controller.dart';
import '../../../data/models/leaderboard_model.dart';
import '../../../data/services/dio_service.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF005AB4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF005AB4),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: controller.previousDay,
                ),
                Obx(() => Text(
                      controller.formattedDate,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                Obx(() => IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: controller.isToday ? Colors.transparent : Colors.white,
                      ),
                      onPressed: controller.isToday ? null : controller.nextDay,
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF005AB4)));
              }

              if (controller.users.isEmpty) {
                return const Center(child: Text('Leaderboard masih kosong.', style: TextStyle(color: Colors.grey)));
              }

              final currentUserRank = controller.currentUserRank;

              return Column(
                children: [
                  // Top 3 Podium
                  if (controller.users.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 40),
                      decoration: const BoxDecoration(
                        color: Color(0xFF005AB4),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (controller.users.length > 1)
                      _buildPodium(controller.users[1], 2, 100),
                    if (controller.users.isNotEmpty)
                      _buildPodium(controller.users[0], 1, 130),
                    if (controller.users.length > 2)
                      _buildPodium(controller.users[2], 3, 90),
                  ],
                ),
              ),

            // Current User Rank Banner
            if (currentUserRank != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                  border: Border.all(color: const Color(0xFF005AB4).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005AB4).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '#${currentUserRank.rank}',
                        style: const TextStyle(color: Color(0xFF005AB4), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Peringkat Anda', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            currentUserRank.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(currentUserRank.points)} pts',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005AB4), fontSize: 16),
                    ),
                  ],
                ),
              ),

            // Rest of the List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.users.length > 3 ? controller.users.length - 3 : 0,
                itemBuilder: (context, index) {
                  final user = controller.users[index + 3];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${user.rank}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!.startsWith('http')
                                  ? user.avatarUrl!
                                  : '${DioService.baseStorageUrl}${user.avatarUrl}')
                              : null,
                          child: user.avatarUrl == null
                              ? Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          NumberFormat('#,###').format(user.points),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF005AB4)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      })),
        ],
      ),
    );
  }

  Widget _buildPodium(LeaderboardModel user, int rank, double height) {
    final colors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 35 : 28,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: rank == 1 ? 32 : 25,
                backgroundColor: Colors.grey[200],
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!.startsWith('http')
                        ? user.avatarUrl!
                        : '${DioService.baseStorageUrl}${user.avatarUrl}')
                    : null,
                child: user.avatarUrl == null
                    ? Text(user.name[0].toUpperCase(), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: rank == 1 ? 24 : 18))
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors[rank],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$rank',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 80,
          child: Text(
            user.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${NumberFormat('#,###').format(user.points)} pts',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
