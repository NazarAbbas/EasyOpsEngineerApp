import 'package:get/get.dart';

class CancelWorkOrderControllerFromDiagnostics extends GetxController {
  // UI state
  final isLoading = false.obs;
  final reasons = const <String>[
    'Busy with Critical',
    'Shift Over',
    'Machine Not Available',
    'Waiting for Parts',
    'Other',
  ];
  final selectedReason = RxnString('Busy with Critical');
  final remarks = ''.obs;

  void onReasonChanged(String? v) => selectedReason.value = v;

  Future<void> submit() async {
    if (selectedReason.value == null || selectedReason.value!.isEmpty) {
      Get.snackbar('Missing reason', 'Please select a reason.');
      return;
    }
    try {
      isLoading.value = true;
      await CancelWorkOrderApi.cancel(
        workOrderId: '1',
        reason: selectedReason.value!,
        remarks: remarks.value.trim().isEmpty ? null : remarks.value.trim(),
      );
      isLoading.value = false;
      Get.back(result: true); // pop with success
      Get.snackbar('Success', 'Work order canceled');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to cancel work order');
    }
  }

  void discard() {
    Get.back(result: false);
  }
}

class CancelWorkOrderApi {
  /// Fake API call: cancels the work order with a reason + remarks.
  static Future<void> cancel({
    required String workOrderId,
    required String reason,
    String? remarks,
  }) async {
    // simulate latency
    await Future.delayed(const Duration(seconds: 2));

    // You could throw to simulate failure:
    // throw Exception('Network error');
  }
}
