import 'dart:async';
import 'package:easy_ops/route_managment/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  // Add to class:
  final phone = ''.obs;
  String get maskedPhone {
    final p = phone.value;
    if (p.isEmpty) return '';
    final last4 = p.replaceAll(RegExp(r'[^\d]'), '');
    if (last4.length < 4) return p;
    return '••••••${last4.substring(last4.length - 4)}';
  }

  // Countdown (seconds)
  final remainingSeconds = 120.obs;
  Timer? _timer;

  // OTP
  final otpCode = ''.obs;
  final otpController = TextEditingController();

  // Loading flags
  final isInitLoading = false.obs; // ← initial API fetch
  final isResending = false.obs; // ← resend API
  final isVerifying = false.obs; // ← verify API

  bool get isBusy =>
      isInitLoading.value || isResending.value || isVerifying.value;

  /// Enabled only when no timer + not loading resend/verify
  bool get canResend =>
      remainingSeconds.value == 0 && !isResending.value && !isVerifying.value;

  /// Seconds-only label like "118s"
  String get remainingLabel => '${remainingSeconds.value}s';

  @override
  void onInit() {
    super.onInit();

    // Read phone passed from login
    final args = Get.arguments;
    if (args is Map && args['phone'] is String) {
      phone.value = args['phone'] as String;
    } else if (args is String) {
      phone.value = args;
    }

    // your existing initial loading + startTimer() after delay
    _bootstrap(); // simulate API before starting countdown
  }

  /// Simulate initial "send OTP" API, then start the countdown.
  Future<void> _bootstrap() async {
    isInitLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // mock API delay
    isInitLoading.value = false;
    startTimer(120);
  }

  /// Start/restart countdown. Resets to [seconds] each time.
  void startTimer([int seconds = 120]) {
    _timer?.cancel();
    remainingSeconds.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = remainingSeconds.value - 1;
      if (next >= 0) remainingSeconds.value = next;
      if (next <= 0) t.cancel();
    });
  }

  Future<void> resendCode() async {
    if (!canResend) return;

    isResending.value = true;
    await Future.delayed(const Duration(seconds: 2)); // mock API delay
    isResending.value = false;

    startTimer(120); // restart countdown after successful resend
    Get.snackbar("OTP", "Code sent again", snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> verifyCode() async {
    if (isBusy) return;

    final code = otpController.text.trim();
    if (code.length != 4) {
      Get.snackbar(
        "Invalid",
        "Please enter the 4-digit code",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isVerifying.value = true;
    await Future.delayed(const Duration(seconds: 2)); // mock API delay
    isVerifying.value = false;

    Get.offNamed(Routes.updatePasswordScreen);
  }

  @override
  void onClose() {
    _timer?.cancel();
    //otpController.dispose();
    super.onClose();
  }
}
