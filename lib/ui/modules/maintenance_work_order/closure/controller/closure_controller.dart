import 'package:easy_ops/ui/modules/maintenance_work_order/closure/ui/closure_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/rca_analysis/controller/rca_analysis_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClosureController extends GetxController {
  // UI state
  final isLoading = false.obs;
  // in ClosureController
  final Rxn<SignatureResult> signatureResult = Rxn<SignatureResult>();
  final Rxn<RcaResult> rcaResult = Rxn<RcaResult>();
  // Dropdown
  final resolutionTypes = <String>[
    'Belt Problem',
    'Electrical Fault',
    'Calibration',
    'Software Glitch',
  ];
  final selectedResolution = 'Belt Problem'.obs;

  // Note
  final noteController = TextEditingController();

  // Accordions
  final sparesOpen = true.obs;
  final rcaOpen = true.obs;
  final pendingOpen = true.obs;

  // Spares figures (demo)
  final sparesConsumedNos = 20.obs;
  final sparesConsumedCost = 2000.obs;
  final sparesIssuedNos = 20.obs;
  final sparesIssuedCost = 2000.obs;
  final sparesToReturnNos = 0.obs;
  final sparesToReturnCost = 0.obs;

  Future<void> resolveWorkOrder() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // ← fake API
    isLoading.value = false;

    Get.snackbar(
      'Resolved',
      'Work order has been resolved successfully.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
    );
  }
}
