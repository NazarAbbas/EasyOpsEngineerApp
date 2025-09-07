// ignore_for_file: file_names

import 'package:easy_ops/ui/modules/login/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePasswordController extends GetxController {
  // Text fields
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // UI state
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isUpdating = false.obs; // <-- loader flag

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  Future<void> updatePassword() async {
    if (isUpdating.value) return; // guard against double taps

    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _err('Please fill all fields');
      return;
    }
    if (password != confirm) {
      _err('Passwords do not match');
      return;
    }

    isUpdating.value = true;
    try {
      // 🔁 simulate API latency
      await Future.delayed(const Duration(seconds: 2));

      // ✅ success flow
      Get.off(() => LoginPage());
      Get.snackbar(
        'Success!',
        'Password updated successfully.\nPlease login again to continue.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      _err('Something went wrong. Please try again.');
    } finally {
      isUpdating.value = false;
    }
  }

  void _err(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
