import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';
import 'dart:ui';

class SignupView extends GetView<SignupController> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // Background Ornaments
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 192,
            left: -128,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            right: MediaQuery.of(context).size.width * 0.25 - 250,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Blur effect for ornaments
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Sharp circular elements
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: -45,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -35,
            right: 35,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
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
                      // Application Logo
                      Image.asset(
                        'assets/images/logo smart-worklife trans.png',
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.work_outline,
                            size: 80,
                            color: primary,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Welcome text
                      const Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join Smart-WorkLife Assistant',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: onSurfaceVariant,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Full Name Field
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: controller.fullNameController,
                        decoration: InputDecoration(
                          hintText: 'John Doe',
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
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'name@company.com',
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
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: controller.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••',
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
                      
                      // Confirm Password Field
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Confirm Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••',
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
                      const SizedBox(height: 24),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: controller.signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Google Sign Up Button
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata, size: 24, color: onSurface),
                        label: const Text(
                          'Sign up with Google',
                          style: TextStyle(
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
                      ),
                      const SizedBox(height: 32),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: onSurfaceVariant,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          TextButton(
                            onPressed: controller.goToLogin,
                            child: const Text(
                              'Log in',
                              style: TextStyle(
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
