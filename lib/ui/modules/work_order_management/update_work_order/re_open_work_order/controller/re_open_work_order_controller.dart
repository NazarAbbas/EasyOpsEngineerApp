// reopen_work_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReopenWorkOrderController extends GetxController {
  // ------- Header card (mock)
  final woId = 'BD-102'.obs;
  final summary = 'Tool misalignment and spindle speed issues in Bay 3.'.obs;
  final priority = 'High'.obs;
  final category = 'Mechanical'.obs;
  final status = 'In Progress'.obs;
  final time = '18:08'.obs;
  final date = '09 Aug'.obs;
  final duration = '1h 20m'.obs;
  //final isReopen = false.obs;

  // ------- Form
  final reasons = const [
    'Select Reason',
    'Problem Persists',
    'Incorrect Closure',
    'Parts Unavailable',
    'Safety Issue',
    'Other',
  ];
  final selectedReason = 'Select Reason'.obs;
  final remarkCtrl = TextEditingController();

  @override
  void onClose() {
    remarkCtrl.dispose();
    super.onClose();
  }

  /// Validate inputs (used by UI before showing overlay)
  bool validate() {
    if (selectedReason.value == reasons.first) {
      Get.snackbar(
        'Select a reason',
        'Please select a re-open reason to proceed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  /// Fake API call (2s) then pop with result + snackbar
  Future<void> reOpen() async {
    //isReopen.value = true;
    final payload = {
      'workOrderId': woId.value,
      'reason': selectedReason.value,
      'remark': remarkCtrl.text.trim(),
    };

    await Future.delayed(const Duration(seconds: 10)); // ← fake network

    Get.back(result: payload);
    Get.snackbar(
      'Re-Opened',
      'Work order has been re-opened.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void discard() {
    selectedReason.value = reasons.first;
    remarkCtrl.clear();
    Get.snackbar(
      'Discarded',
      'Changes cleared.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
