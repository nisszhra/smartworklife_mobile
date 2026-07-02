import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worklife_mobile/app/routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class SecurityView extends GetView<ProfileController> {
  const SecurityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF9F9FF);
    const Color primary = Color(0xFF005AB4);
    
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Akun & Keamanan',
          style: TextStyle(
            color: Color(0xFF181C22),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181C22)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC1C6D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 20, color: primary),
                        const SizedBox(width: 8),
                        Obx(() => Text(
                          controller.hasPassword ? 'Ubah Password' : 'Buat Password',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181C22),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Obx(() => controller.hasPassword
                        ? Column(
                            children: [
                              _buildPasswordField(
                                label: 'Current Password',
                                controller: controller.currentPasswordController,
                                isVisible: controller.showCurrentPassword.value,
                                onToggle: controller.toggleCurrentPassword,
                              ),
                              const SizedBox(height: 16),
                            ],
                          )
                        : const SizedBox.shrink()),
                    Obx(() => _buildPasswordField(
                          label: 'New Password',
                          controller: controller.newPasswordController,
                          isVisible: controller.showNewPassword.value,
                          onToggle: controller.toggleNewPassword,
                        )),
                    const SizedBox(height: 16),
                    Obx(() => _buildPasswordField(
                          label: 'Confirm New Password',
                          controller: controller.confirmPasswordController,
                          isVisible: controller.showConfirmPassword.value,
                          onToggle: controller.toggleConfirmPassword,
                        )),
                    const SizedBox(height: 24),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () {
                                controller.changePassword();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSaving.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                controller.hasPassword ? 'Ubah Password' : 'Buat Password',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )),
                      Obx(() => controller.hasPassword
                          ? Column(
                              children: [
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () {
                                      Get.toNamed(Routes.FORGOT_PASSWORD);
                                    },
                                    child: const Text(
                                      'Lupa Password?',
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const SizedBox(height: 16),
                                if (controller.isSnoozed)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9C4),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFBC02D)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Untuk keamanan maksimal, sebaiknya Anda segera membuat password untuk melindungi akun ini.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFFF57F17),
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: () {
                                        controller.snoozePasswordReminder();
                                        Get.back();
                                        Get.snackbar(
                                          'Diingatkan Nanti', 
                                          'Anda dapat membuat password kapan saja melalui menu ini.', 
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: const Color(0xFFFFF9C4),
                                          colorText: const Color(0xFF181C22),
                                        );
                                      },
                                      child: const Text(
                                        'Nanti Saja',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC1C6D5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFDC2626)),
                        SizedBox(width: 8),
                        Text(
                          'Zona Bahaya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Menghapus akun Anda akan menghapus seluruh data secara permanen dan tidak dapat dipulihkan kembali.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: controller.deleteAccount,
                        icon: const Icon(Icons.delete_forever, color: Color(0xFFDC2626), size: 20),
                        label: const Text(
                          'Hapus Akun Permanen',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFFFED7D7)),
                          ),
                          backgroundColor: const Color(0xFFFFF5F5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF717785),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF181C22),
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline,
                size: 20, color: Color(0xFF94A3B8)),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                size: 20,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFFF9F9FF),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF005AB4), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
