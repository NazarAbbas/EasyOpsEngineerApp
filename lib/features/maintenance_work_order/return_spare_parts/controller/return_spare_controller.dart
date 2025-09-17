// lib/ui/modules/maintenance_work_order/return_spare_parts/controller/return_spare_controller.dart
import 'package:easy_ops/features/maintenance_work_order/closure/controller/closure_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReturnSparesController extends GetxController {
  final isSaving = false.obs;

  /// Hardcoded catalog for demo; in real app, fetch this list.
  final items = <SpareItem>[
    SpareItem(name: 'Spindle Motor', code: 'SM-1001', cost: 10, requested: 10),
    SpareItem(name: 'Ball Screws', code: 'BS-2002', cost: 10, requested: 10),
    SpareItem(
      name: 'Linear Guide Rails',
      code: 'LGR-3003',
      cost: 10,
      requested: 10,
    ),
    SpareItem(name: 'Tool Holders', code: 'TH-4004', cost: 10, requested: 10),
    SpareItem(name: 'Cutting Tools', code: 'CT-5005', cost: 10, requested: 10),
    SpareItem(
      name: 'Proximity Sensors',
      code: 'PS-8008',
      cost: 10,
      requested: 10,
    ),
  ].obs;

  int get totalReturning => items.fold(0, (sum, e) => sum + e.returning.value);

  @override
  void onInit() {
    super.onInit();

    // Prefill from arguments: expecting List<SpareReturnItem> (from Closure)
    final arg = Get.arguments;
    if (arg is List<SpareReturnItem>) {
      final byCode = {for (final it in arg) it.id: it}; // id == code here
      for (final item in items) {
        final pre = byCode[item.code];
        if (pre != null) {
          // clamp within requested range
          final qty = pre.nos.clamp(0, item.requested);
          item.returning.value = qty;
        }
      }
    }
  }

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

    // Build result for Closure screen: List<SpareReturnItem>
    final selected = items
        .where((e) => e.returning.value > 0)
        .map(
          (e) => SpareReturnItem(
            id: e.code, // using code as a unique id
            name: e.name,
            nos: e.returning.value,
            cost: e.cost, // no price context here; Closure can keep 0
          ),
        )
        .toList();

    // Pop and return the selected items list
    Get.back(result: selected);

    // Optional toast (won’t block navigation)
    if (selected.isEmpty) {
      Get.snackbar(
        'No Items Selected',
        'You didn’t select any items to return.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } else {
      Get.snackbar(
        'Spares Returned',
        'Returning $totalReturning item(s).',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  void onDiscard() => Get.back();
}

class SpareItem {
  final String name;
  final String code;
  final double cost;
  final int requested;
  final RxInt returning;

  SpareItem({
    required this.name,
    required this.code,
    required this.cost,
    required this.requested,
    int initialReturning = 0,
  }) : returning = (initialReturning).obs;
}
