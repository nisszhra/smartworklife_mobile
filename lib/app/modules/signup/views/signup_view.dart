import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;

    // Colors from the design
    const Color background = Color(0xFFF9F9FF);
    const Color primary = Color(0xFF005AB4);
    const Color onSurface = Color(0xFF181C22);
    const Color outlineVariant = Color(0xFFC1C6D5);
    const Color surfaceContainerLowest = Color(0xFFFFFFFF);
    const Color onPrimary = Color(0xFFFFFFFF);
    const Color onSurfaceVariant = Color(0xFF414753);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo smart-worklife trans.png',
                        height: 100, // Adjust height as needed
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),

                      // Welcome text
                      Text(
                        'create_account'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'join_assistant'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: onSurfaceVariant,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Full Name Field
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'full_name'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: ctrl.fullNameController,
                        decoration: InputDecoration(
                          hintText: 'full_name_hint'.tr,
                          hintStyle: const TextStyle(color: outlineVariant),
                          filled: true,
                          fillColor: surfaceContainerLowest,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'email_address'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: ctrl.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'email_hint'.tr,
                          hintStyle: const TextStyle(color: outlineVariant),
                          filled: true,
                          fillColor: surfaceContainerLowest,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'password_label'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Obx(() => TextFormField(
                        controller: ctrl.passwordController,
                        obscureText: !ctrl.isPasswordVisible.value,
                        decoration: InputDecoration(
                          hintText: 'password_hint'.tr,
                          hintStyle: const TextStyle(color: outlineVariant),
                          filled: true,
                          fillColor: surfaceContainerLowest,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              ctrl.isPasswordVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: outlineVariant,
                            ),
                            onPressed: ctrl.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: primary, width: 2),
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),
                      
                      // Confirm Password Field
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'confirm_password'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Obx(() => TextFormField(
                        controller: ctrl.confirmPasswordController,
                        obscureText: !ctrl.isConfirmPasswordVisible.value,
                        decoration: InputDecoration(
                          hintText: 'confirm_password_hint'.tr,
                          hintStyle: const TextStyle(color: outlineVariant),
                          filled: true,
                          fillColor: surfaceContainerLowest,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              ctrl.isConfirmPasswordVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: outlineVariant,
                            ),
                            onPressed: ctrl.toggleConfirmPasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: primary, width: 2),
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),
                      // Error message
                      Obx(() => ctrl.errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                ctrl.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                      // Sign Up Button
                      Obx(() => ElevatedButton(
                        onPressed: ctrl.isLoading.value ? null : ctrl.signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: ctrl.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'sign_up'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                ),
                              ),
                      )),
                      const SizedBox(height: 16),
                      
                      // Google Sign Up Button
                      Obx(() => OutlinedButton.icon(
                        onPressed: ctrl.isLoading.value ? null : ctrl.signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 24, color: onSurface),
                        label: Text(
                          'sign_up_google'.tr,
                          style: const TextStyle(
                            color: onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )),
                      const SizedBox(height: 32),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'already_have_account'.tr,
                            style: const TextStyle(
                              color: onSurfaceVariant,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          TextButton(
                            onPressed: ctrl.goToLogin,
                            child: Text(
                              'log_in'.tr,
                              style: const TextStyle(
                                color: primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
