// ignore_for_file: deprecated_member_use

import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:easy_ops/ui/modules/forgot_password/controller/forgot_password_controller.dart';
import 'package:easy_ops/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ops/constants/values/app_images.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('forgot_password_text'.tr)),
      body: Obx(() {
        final initLoading = controller.isInitLoading.value;

        return Stack(
          children: [
            // Main content
            IgnorePointer(
              ignoring: initLoading, // block touches while initial loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    _ForgotPasswordHeader(
                      imagePath: AppImages.forgotPasswordFrameIcon,
                    ),
                    SizedBox(height: 20),
                    _ForgotPasswordInfoText(),
                    SizedBox(height: 20),
                    _ForgotPasswordOtpField(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ----- Overlays -----
            // Initial loading overlay (simulate initial API: "Send OTP")
            if (initLoading) const LoadingOverlay(message: 'Sending OTP…'),

            // Action-specific overlays
            if (controller.isVerifying.value)
              const LoadingOverlay(message: 'Verifying OTP…'),
            if (controller.isResending.value)
              const LoadingOverlay(message: 'Resending OTP…'),
          ],
        );
      }),
      bottomNavigationBar: const _ForgotPasswordButtons(),
    );
  }
}

class _ForgotPasswordButtons extends StatelessWidget {
  const _ForgotPasswordButtons();

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final c = Get.find<ForgotPasswordController>();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Obx(() {
      final sending = c.isResending.value;
      final verifying = c.isVerifying.value;
      final canResend = c.canResend;
      final initLoading = c.isInitLoading.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 60.0, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // RESEND
            Expanded(
              flex: isTablet ? 2 : 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: canResend
                      ? primary
                      : primary.withOpacity(0.6),
                  side: BorderSide(
                    color: canResend ? primary : primary.withOpacity(0.4),
                  ),
                  minimumSize: Size(double.infinity, isTablet ? 55 : 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (canResend && !sending && !verifying && !initLoading)
                    ? c.resendCode
                    : null,
                child: sending
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text("Sending…"),
                        ],
                      )
                    : Text(
                        canResend
                            ? "Resend Code"
                            : "Resend in ${c.remainingLabel}",
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // VERIFY
            Expanded(
              flex: isTablet ? 2 : 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  minimumSize: Size(double.infinity, isTablet ? 55 : 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (verifying || initLoading) ? null : c.verifyCode,
                child: verifying
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Verifying…",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : const Text(
                        "Verify Code",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ForgotPasswordHeader extends StatelessWidget {
  final String imagePath;
  const _ForgotPasswordHeader({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = w > 600 ? 300.0 : 200.0;
    return Center(child: Image.asset(imagePath, height: h));
  }
}

class _ForgotPasswordInfoText extends StatelessWidget {
  const _ForgotPasswordInfoText();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ForgotPasswordController>();
    final w = MediaQuery.of(context).size.width;
    final fs = w > 600 ? 18.0 : 14.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Obx(
      () => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  "We have sent a code on your registered phone\n"
                  "number ending with ${c.maskedPhone}.\n"
                  "This code will expire in: ",
              style: TextStyle(fontSize: fs, color: Colors.black54),
            ),
            TextSpan(
              text: c.remainingLabel, // mm:ss or ss based on your controller
              style: TextStyle(
                fontSize: fs,
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordOtpField extends StatelessWidget {
  const _ForgotPasswordOtpField();

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final c = Get.find<ForgotPasswordController>();
    final w = MediaQuery.of(context).size.width;
    final isTablet = w > 600;

    return Obx(() {
      final readOnly = c.isVerifying.value || c.isInitLoading.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: PinCodeTextField(
          appContext: context,
          length: 4,
          readOnly: readOnly,
          keyboardType: TextInputType.number,
          animationType: AnimationType.fade,
          textStyle: TextStyle(
            fontSize: isTablet ? 24 : 20,
            color: primary,
            fontWeight: FontWeight.w600,
          ),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            fieldHeight: isTablet ? 70 : 50,
            fieldWidth: isTablet ? 60 : 40,
            inactiveColor: Colors.grey,
            activeColor: primary,
            selectedColor: primary,
          ),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          onChanged: (v) => c.otpCode.value = v,
          controller: c.otpController,
        ),
      );
    });
  }
}
