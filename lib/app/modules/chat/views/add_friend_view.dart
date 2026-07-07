import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class AddFriendView extends GetView<ChatController> {
  const AddFriendView({super.key});

  @override
  Widget build(BuildContext context) {
    // Reset state saat halaman dibuka (jika diperlukan)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.friendNameController.clear();
      controller.searchResult.value = null;
      controller.searchError.value = '';
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_alt_1, color: Color(0xFF005AB4)),
            const SizedBox(width: 8),
            Text(
              'add_friend_title'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF005AB4),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF005AB4), size: 24),
          onPressed: () {
            controller.friendNameController.clear();
            controller.searchResult.value = null;
            controller.searchError.value = '';
            Get.back();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'find_colleagues'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'search_by_username_desc'.tr,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.friendNameController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'enter_username_hint'.tr,
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF005AB4), size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                      onSubmitted: (val) {
                        final name = val.trim();
                        if (name.isNotEmpty) {
                          controller.searchUser(name);
                        }
                      },
                      onChanged: (val) {
                        if (controller.searchResult.value != null || controller.searchError.value.isNotEmpty) {
                          controller.searchResult.value = null;
                          controller.searchError.value = '';
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isSearching.value
                              ? null
                              : () {
                                  final name = controller.friendNameController.text.trim();
                                  if (name.isNotEmpty) controller.searchUser(name);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005AB4),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isSearching.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text('search'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Search Result
            Obx(() {
              if (controller.isSearching.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: Color(0xFF005AB4)),
                  ),
                );
              }
              
              if (controller.searchError.value.isNotEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFEDD5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'not_found'.tr,
                        style: const TextStyle(
                          color: Color(0xFFC2410C),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchError.value,
                        style: const TextStyle(
                          color: Color(0xFFC2410C),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final foundUser = controller.searchResult.value;
              if (foundUser == null) {
                return const SizedBox.shrink();
              }
              
              final foundName = foundUser.fullName ?? foundUser.email;
              
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF005AB4).withOpacity(0.1),
                    child: Text(
                      foundName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF005AB4), 
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    foundName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                       controller.addFriendFromSearch();
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('add'.tr, style: const TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005AB4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
