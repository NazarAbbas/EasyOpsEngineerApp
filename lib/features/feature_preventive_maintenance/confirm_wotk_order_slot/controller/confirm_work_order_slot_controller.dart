// confirm_slot_controller.dart
// Full controller + model + fake API (null-safe, no force unwraps)

import 'dart:async';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/feature_preventive_maintenance/confirm_wotk_order_slot/models/confirm_work_order_slot_model.dart';
import 'package:get/get.dart';

class PreventiveWorkOrderController extends GetxController {
  // Make api optional with a sensible default so bindings are easy.
  final SlotsApi api;
  PreventiveWorkOrderController({SlotsApi? api}) : api = api ?? SlotsApi();

  // UI state
  final isLoading = true.obs;
  final slots = <SlotOption>[].obs;
  final selectedSlotId = RxnString();

  // Metadata (wire from previous screen if needed)
  final workOrderId = 'WO-1024';
  final machineName = 'CNC-1';
  final brand = 'Siemens';
  final location = 'CNC Vertical Assets Center where we make housing';
  final runningStatusText = 'Working';
  final severityText = 'Critical';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final data = await api.fetchSlots(workOrderId: workOrderId);
      slots.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load slots',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectSlot(String? id) => selectedSlotId.value = id;

  Future<void> confirmSelection() async {
    Get.toNamed(Routes.preventiveStartWorkScreen);

    // Get.offAllNamed(
    //   Routes.preventiveDashboardScreen,
    //   arguments: {'tab': 3}, // open Work Orders
    // );

    // final id = selectedSlotId.value;
    // if (id == null) {
    //   Get.snackbar(
    //     'Select a slot',
    //     'Please choose a slot first',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    //   return;
    // }
    // isLoading.value = true;
    // try {
    //   await Future.delayed(const Duration(milliseconds: 600));
    //   Get.snackbar(
    //     'Confirmed',
    //     'Your slot has been confirmed',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // } finally {
    //   isLoading.value = false;
    // }
  }

  void addProposedSlot(String label) {
    final newId = 'p${DateTime.now().millisecondsSinceEpoch}';
    slots.add(SlotOption(newId, label));
    selectedSlotId.value = newId;
    Get.snackbar(
      'Proposed',
      'New slot added',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
