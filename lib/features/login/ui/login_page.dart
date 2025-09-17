// ignore_for_file: deprecated_member_use
import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/core/theme/app_images.dart';
import 'package:easy_ops/features/login/controller/login_controller.dart';
import 'package:easy_ops/core/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<LoginPageController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        return Stack(
          children: [
            // ---- Main content ----
            LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                return Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: BlueBackgroundPainter(primary),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 500 : double.infinity,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: isTablet ? 100 : 80),
                              _LoginLogo(isTablet: isTablet),
                              SizedBox(height: isTablet ? 50 : 40),
                              _LoginCard(
                                controller: controller,
                                isTablet: isTablet,
                              ),
                              SizedBox(height: isTablet ? 40 : 30),
                              const _LoginFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // ---- Blur + barrier + spinner when loading ----
            if (isLoading) const LoadingOverlay(message: 'Authenticating…'),
          ],
        );
      }),
    );
  }
}

class BlueBackgroundPainter extends CustomPainter {
  final Color primary;
  const BlueBackgroundPainter(this.primary);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = primary;
    final path = Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 140,
        size.width,
        size.height,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BlueBackgroundPainter oldDelegate) {
    return oldDelegate.primary != primary;
  }
}

class _LoginCard extends StatelessWidget {
  final LoginPageController controller;
  final bool isTablet;
  const _LoginCard({required this.controller, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final vPad = isTablet ? 18.0 : 14.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final loading = controller.isLoading.value;

        // AbsorbPointer here is optional because we already add a full-screen barrier.
        // Keeping it ensures no inner focus changes while loading.
        return AbsorbPointer(
          absorbing: loading,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.all(isTablet ? 30 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'login_to_account'.tr,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                _LoginTextField(
                  controller: controller.emailController,
                  label: 'phone_or_email'.tr,
                  hint: 'enter_registered'.tr,
                ),
                const SizedBox(height: 15),

                Obx(
                  () => _LoginTextField(
                    controller: controller.passwordController,
                    label: 'password'.tr,
                    obscureText: !controller.isPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),

                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: controller.forgotPassword,
                    child: Text(
                      'forgot_password'.tr,
                      style: TextStyle(color: primary),
                    ),
                  ),
                ),

                SizedBox(height: vPad),

                // Login button (disabled while loading; no inline spinner)
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final loading = controller.isLoading.value;
                    return ElevatedButton(
                      onPressed: loading ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: primary.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: vPad),
                      ),
                      child: loading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text("Logging…"),
                              ],
                            )
                          : Text(
                              'login'.tr,
                              style: TextStyle(fontSize: isTablet ? 20 : 16),
                            ),
                    );
                  }),
                ),

                const SizedBox(height: 15),
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text("or".tr),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 15),

                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        AppImages.fingerPrint,
                        width: isTablet ? 70 : 50,
                        height: isTablet ? 70 : 50,
                      ),
                      const SizedBox(height: 10),
                      Text('login_biometric'.tr),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final Widget? suffixIcon;

  const _LoginTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '*',
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.lightGray),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text.rich(
        TextSpan(
          text: '${'help_text'.tr} ',
          style: TextStyle(color: Colors.grey[600]),
          children: [
            TextSpan(
              text: 'contact@eazyops.in',
              style: TextStyle(
                color: primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ), // or FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginLogo extends StatelessWidget {
  final bool isTablet;
  const _LoginLogo({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AppImages.gearIcon,
          width: isTablet ? 70 : 50,
          height: isTablet ? 70 : 50,
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        Text(
          'EazyOps',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 68 : 46,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
