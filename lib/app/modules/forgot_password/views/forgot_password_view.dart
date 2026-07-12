import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Colors for consistency with signup and verifikasi
    const Color background = Color(0xFFF9F9FF);
    const Color primary = Color(0xFF005AB4);
    const Color onSurface = Color(0xFF181C22);
    const Color outlineVariant = Color(0xFFC1C6D5);
    const Color surfaceContainerLowest = Color(0xFFFFFFFF);
    const Color onPrimary = Color(0xFFFFFFFF);
    const Color onSurfaceVariant = Color(0xFF414753);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                color: surfaceContainerLowest,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Obx(() {
                    final isEmailStep = controller.currentStep.value == ForgotPasswordStep.inputEmail;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/Smart-WorkLife_transparant1.png',
                          height: 80,
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          isEmailStep ? 'forgot_password_title'.tr : 'reset_password_title'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          isEmailStep
                              ? 'forgot_password_desc'.tr
                              : 'reset_password_desc'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Inputs
                        if (isEmailStep) ...[
                          _buildTextField(
                            controller: controller.emailController,
                            hintText: 'enter_email'.tr,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ] else ...[
                          _buildTextField(
                            controller: controller.otpController,
                            hintText: 'otp_code'.tr,
                            prefixIcon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                          const SizedBox(height: 16),
                          Obx(() => _buildTextField(
                            controller: controller.newPasswordController,
                            hintText: 'new_password_hint'.tr,
                            prefixIcon: Icons.lock_outline,
                            obscureText: !controller.isPasswordVisible.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: onSurfaceVariant,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          )),
                          const SizedBox(height: 16),
                          Obx(() => _buildTextField(
                            controller: controller.confirmNewPasswordController,
                            hintText: 'confirm_new_password_hint'.tr,
                            prefixIcon: Icons.lock_outline,
                            obscureText: !controller.isConfirmPasswordVisible.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: onSurfaceVariant,
                              ),
                              onPressed: controller.toggleConfirmPasswordVisibility,
                            ),
                          )),
                        ],

                        const SizedBox(height: 24),

                        // Error message
                        if (controller.errorMessage.value.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : (isEmailStep ? controller.sendOtp : controller.resetPassword),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEmailStep ? 'send_otp'.tr : 'reset_password_title'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Back Button
                        GestureDetector(
                          onTap: controller.kembali,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_back, size: 16, color: onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                'back_to_login'.tr,
                                style: const TextStyle(
                                  color: onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    const Color primary = Color(0xFF005AB4);
    const Color outlineVariant = Color(0xFFC1C6D5);
    
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'Inter'),
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8B92A5), fontFamily: 'Inter'),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF8B92A5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF0F4F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
