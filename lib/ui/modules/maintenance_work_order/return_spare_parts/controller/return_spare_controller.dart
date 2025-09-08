import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/* ───────────────────────── Controller ───────────────────────── */

class ReturnSparesController extends GetxController {
  final isSaving = false.obs;

  final items = <SpareItem>[
    SpareItem(name: 'Spindle Motor', code: 'SM-1001', requested: 10),
    SpareItem(name: 'Ball Screws', code: 'BS-2002', requested: 10),
    SpareItem(name: 'Linear Guide Rails', code: 'LGR-3003', requested: 10),
    SpareItem(name: 'Tool Holders', code: 'TH-4004', requested: 10),
    SpareItem(name: 'Cutting Tools', code: 'CT-5005', requested: 10),
    SpareItem(name: 'Proximity Sensors', code: 'PS-8008', requested: 10),
  ].obs;

  int get totalReturning => items.fold(0, (sum, e) => sum + e.returning.value);

  void inc(SpareItem item) {
    if (item.returning.value < item.requested) {
      item.returning.value++;
    }
  }

  void dec(SpareItem item) {
    if (item.returning.value > 0) {
      item.returning.value--;
    }
  }

  Future<void> onReturn() async {
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 900)); // fake API
    isSaving.value = false;

    final payload = items
        .where((e) => e.returning.value > 0)
        .map((e) => {'code': e.code, 'qty': e.returning.value})
        .toList();

    Get.snackbar(
      'Spares Returned',
      payload.isEmpty
          ? 'No items selected.'
          : 'Returning $totalReturning item(s).',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );

    // Send payload to backend or pop with result:
    // Get.back(result: payload);
  }

  void onDiscard() => Get.back();
}

class SpareItem {
  final String name;
  final String code;
  final int requested;
  final RxInt returning;

  SpareItem({
    required this.name,
    required this.code,
    required this.requested,
    int initialReturning = 0,
  }) : returning = (initialReturning).obs;
}
