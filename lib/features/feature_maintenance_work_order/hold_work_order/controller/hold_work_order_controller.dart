// hold_work_order_page.dart
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ───────────────────────── Controller ─────────────────────────
class HoldWorkOrderController extends GetxController {
  // Work order info (normally injected)
  final String woTitle = 'Conveyor Belt Stopped Abruptly During Operation';
  final String priority = 'High';
  final String status = 'In Progress';
  final String code = 'BD-102';
  final String time = '18:08';
  final String date = '09 Aug';
  final String department = 'Mechanical';
  final String eta = '1h 20m';

  // Context (top middle card)
  final RxString holdContextTitle = 'Need Hydra'.obs;
  final RxString holdContextCategory = 'Assets Availability'.obs;
  final RxString holdContextDesc =
      'Live offline shoulder see gave group like loop. Container.'.obs;

  // Form state
  final TextEditingController reasonTitleCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();
  final RxString reasonTitle = ''.obs;

  final RxList<String> reasonTypes = <String>[
    'Assets Availability/ Manpower/spare/skill',
    'Safety/Permit Pending',
    'Process Dependency',
    'Awaiting Vendor',
    'Other',
  ].obs;
  final RxString selectedReasonType = ''.obs;

  final RxString remarks = ''.obs;

  // submit state
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    selectedReasonType.value = reasonTypes.first;
    super.onInit();
  }

  @override
  void onClose() {
    reasonTitleCtrl.dispose();
    remarksCtrl.dispose();
    super.onClose();
  }

  bool get canSubmit =>
      reasonTitle.value.trim().isNotEmpty &&
      selectedReasonType.value.isNotEmpty;

  Future<void> onEditContext(BuildContext context) async {
    // tiny inline editor (title + desc)
    final titleTemp = TextEditingController(text: holdContextTitle.value);
    final descTemp = TextEditingController(text: holdContextDesc.value);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Hold Context'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleTemp,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descTemp,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              holdContextTitle.value = titleTemp.text.trim().isEmpty
                  ? holdContextTitle.value
                  : titleTemp.text.trim();
              holdContextDesc.value = descTemp.text.trim();
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void onDiscard() => Get.back();

  /// Fake API call
  Future<void> onHold() async {
    if (!canSubmit) {
      Get.snackbar(
        'Missing details',
        'Please add Hold Reason Title',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isSubmitting.value = true;
    try {
      await Future.delayed(const Duration(seconds: 2)); // simulate network
      Get.snackbar(
        'Work Order On Hold',
        'Title: ${reasonTitle.value}\nType: ${selectedReasonType.value}'
            '${remarks.value.isNotEmpty ? '\nRemarks: ${remarks.value}' : ''}',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      // Get.back(); // close page
      Get.offAllNamed(
        Routes.landingDashboardScreen,
        arguments: {'tab': 3}, // open Work Orders
      );
    } catch (_) {
      Get.snackbar(
        'Failed',
        'Could not put on hold. Try again.',
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
