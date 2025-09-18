// closure_controller.dart
import 'dart:convert';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/maintenance_work_order/closure_signature/controller/sign_off_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/pending_activity/controller/pending_activity_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/rca_analysis/controller/rca_analysis_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PendingActivityArgs {
  final List<ActivityItem> initial;
  const PendingActivityArgs({required this.initial});
}

class ClosureController extends GetxController {
  // UI state
  final isLoading = false.obs;

  // collected results
  final Rxn<SignatureResult> signatureResult = Rxn<SignatureResult>();
  final Rxn<RcaResult> rcaResult = Rxn<RcaResult>();
  final RxList<ActivityItem> pendingActivities = <ActivityItem>[].obs;

  // ⬇️ Spares to be returned (coming from next page)
  final RxList<SpareReturnItem> sparesToReturn = <SpareReturnItem>[].obs;

  // Derived totals
  int get sparesToReturnNosTotal =>
      sparesToReturn.fold(0, (sum, e) => sum + e.nos);
  double get sparesToReturnCostTotal =>
      sparesToReturn.fold(0, (sum, e) => sum + e.cost);

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
  // final sparesToReturnNos = 0.obs;
  //final sparesToReturnCost = 0.obs;

  /// Collects all data and sends to API
  Future<void> resolveWorkOrder() async {
    // Build request body
    final payload = {
      "resolutionType": selectedResolution.value,
      "note": noteController.text.trim(),
      "signature": signatureResult.value == null
          ? null
          : {
              "empCode": signatureResult.value!.empCode,
              "name": signatureResult.value!.name,
              "designation": signatureResult.value!.designation,
              "time": signatureResult.value!.time.toIso8601String(),
              "bytes": signatureResult.value!.bytes != null
                  ? base64Encode(signatureResult.value!.bytes!)
                  : null,
            },
      "rca": rcaResult.value == null
          ? null
          : {
              "problemIdentified": rcaResult.value!.problemIdentified,
              "fiveWhys": rcaResult.value!.fiveWhys,
              "rootCause": rcaResult.value!.rootCause,
              "correctiveAction": rcaResult.value!.correctiveAction,
            },
      "pendingActivities": pendingActivities
          .map(
            (a) => {
              "id": a.id,
              "title": a.title,
              "type": a.type.name,
              "assignee": a.assignee,
              "targetDate": a.targetDate?.toIso8601String(),
              "note": a.note,
              "status": a.status,
            },
          )
          .toList(),
      "spares": {
        "consumed": {
          "nos": sparesConsumedNos.value,
          "cost": sparesConsumedCost.value,
        },
        "issued": {
          "nos": sparesIssuedNos.value,
          "cost": sparesIssuedCost.value,
        },
        // ⬇️ include items + totals from list
        "toReturn": {
          "nos": sparesToReturnNosTotal,
          "cost": sparesToReturnCostTotal,
          "items": sparesToReturn.map((e) => e.toJson()).toList(),
        },
      },
    };

    isLoading.value = true;
    // Example: replace with your backend endpoint
    // final resp = await http.post(
    //   Uri.parse("https://api.example.com/workorders/resolve"),
    //   headers: {"Content-Type": "application/json"},
    //   body: jsonEncode(payload),
    // );
    await Future.delayed(const Duration(milliseconds: 900));

    isLoading.value = false;

    Get.offAllNamed(
      Routes.landingDashboardScreen,
      arguments: {'tab': 3}, // open Work Orders
    );

    //Get.offAllNamed(Routes.workOrderManagementScreen);

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

// models/spare_return_item.dart
class SpareReturnItem {
  final String id; // e.g. INV-001 / SP-001
  final String name; // e.g. "Bearing 6203"
  final int nos; // quantity to return
  final double cost; // total cost for this line (nos * unitPrice or similar)

  const SpareReturnItem({
    required this.id,
    required this.name,
    required this.nos,
    required this.cost,
  });

  SpareReturnItem copyWith({
    String? id,
    String? name,
    int? nos,
    double? cost,
  }) => SpareReturnItem(
    id: id ?? this.id,
    name: name ?? this.name,
    nos: nos ?? this.nos,
    cost: cost ?? this.cost,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nos": nos,
    "cost": cost,
  };

  factory SpareReturnItem.fromJson(Map<String, dynamic> json) =>
      SpareReturnItem(
        id: json["id"] as String,
        name: json["name"] as String,
        nos: json["nos"] as int,
        cost: json["cost"] as double,
      );
}
