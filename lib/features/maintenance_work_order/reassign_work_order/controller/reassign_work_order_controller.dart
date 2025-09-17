import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ───────────────────────── Controller ─────────────────────────
class ReassignWorkOrderController extends GetxController {
  final RxString selectedReason = ''.obs;
  final RxList<String> reasons = <String>[
    'Busy with Critical',
    'Out of Shift',
    'Lack of Tools',
    'Need Senior Support',
    'On Leave',
  ].obs;

  final TextEditingController remarksCtrl = TextEditingController();
  final RxString remarks = ''.obs;

  // submitting state
  final RxBool isSubmitting = false.obs;

  // Example payload for the card (normally injected)
  final String woTitle = 'Latency Issue in web browser';
  final String priority = 'High';
  final String status = 'In Progress';
  final String code = 'BD-102';
  final String time = '18:08';
  final String date = '09 Aug';
  final String department = 'Mechanical';
  final String eta = '1h 20m';

  @override
  void onInit() {
    remarks.value = remarksCtrl.text;
    selectedReason.value = reasons.first;
    super.onInit();
  }

  @override
  void onClose() {
    remarksCtrl.dispose();
    super.onClose();
  }

  void onDiscard() => Get.back();

  /// Fake API call with loading state
  Future<void> onReassign() async {
    final reason = selectedReason.value;
    final r = remarksCtrl.text.trim();

    isSubmitting.value = true;
    try {
      // simulate network latency
      await Future.delayed(const Duration(seconds: 2));
      Get.back(); // close page (optional)
      // success toast
      Get.snackbar(
        'Reassigned',
        'Successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        'Could not reassign. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade700,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
