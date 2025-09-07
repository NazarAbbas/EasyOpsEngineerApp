// closure_controller.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:easy_ops/route_managment/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class ClosureWorkOrderController extends GetxController {
  // Header basics (mock values)
  final pageTitle = 'Closure'.obs;

  final issueTitle = 'Tool misalignment and spindle speed issues in Bay 3.'.obs;
  final priority = 'High'.obs; // red pill
  final statusText = 'In Progress'.obs; // right link-like text
  final duration = '1h 20m'.obs;

  final workOrderId = 'BD-102'.obs;
  final time = '18:08'.obs;
  final date = '09 Aug'.obs;
  final category = 'Mechanical'.obs;

  // Closure form
  final resolutionTypes = const [
    'Belt Problem',
    'Electrical Fix',
    'Realignment',
    'Other',
  ];
  final selectedResolution = 'Belt Problem'.obs;
  final noteCtrl = TextEditingController();

  // Signature
  late final SignatureController signatureCtrl;
  final hasSignature = false.obs;
  final savedSignaturePath = ''.obs; // optional: where we saved PNG

  // Spares (dummy)
  final sparesExpanded = false.obs;
  final spares = <_Spare>[
    const _Spare('Belt Type A', 2, 200),
    const _Spare('Grease Pack', 1, 150),
    const _Spare('Alignment Shim', 17, 10),
  ].obs;

  int get totalQty => spares.fold(0, (a, b) => a + b.qty);
  int get totalCost => spares.fold(0, (a, b) => a + (b.qty * b.unitPrice));

  // Progress
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    signatureCtrl = SignatureController(
      penColor: const Color(0xFF111827),
      penStrokeWidth: 3,
      exportBackgroundColor: Colors.transparent,
      onDrawEnd: () => hasSignature.value = true,
      onDrawStart: () {}, // optional
    );
  }

  @override
  void onClose() {
    noteCtrl.dispose();
    signatureCtrl.dispose();
    super.onClose();
  }

  void clearSignature() {
    signatureCtrl.clear();
    hasSignature.value = false;
  }

  void toggleSpares() => sparesExpanded.toggle();

  Future<void> reopenWorkOrder() async {
    // Navigate to your Re-open screen route
    Get.toNamed(
      Routes.reOpenWorkOrderScreen,
    ); // replace with Routes.reOpenWorkOrderScreen
  }

  /// Simulates an API call:
  /// - ensures signature exists
  /// - exports signature to PNG and saves locally
  /// - shows a blocking progress dialog
  /// - completes with success + snackbar
  Future<void> closeWorkOrder() async {
    if (!hasSignature.value || signatureCtrl.isEmpty) {
      Get.snackbar(
        'Signature required',
        'Please add your signature to proceed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Export signature to PNG
    final bytes = await signatureCtrl.toPngBytes();

    if (bytes == null || bytes.isEmpty) {
      Get.snackbar(
        'Error',
        'Could not export signature.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Save PNG to app documents (optional, to show persistence)
    final path = await _saveBytes(bytes);
    savedSignaturePath.value = path ?? '';

    // Dummy API call with blocking progress
    isSubmitting.value = true;

    await Future.delayed(const Duration(seconds: 2)); // pretend network call

    isSubmitting.value = false;
    // if (Get.isDialogOpen ?? false) Get.back(); // close loader

    Get.snackbar(
      'Closed',
      'Work order closed successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: const Color(0xFF111827),
    );

    // Navigate where you need (listing, details, etc.)
    // Get.offAllNamed(Routes.workOrderScreen);
  }

  Future<String?> _saveBytes(Uint8List data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}

class _Spare {
  final String name;
  final int qty;
  final int unitPrice; // ₹
  const _Spare(this.name, this.qty, this.unitPrice);
}
