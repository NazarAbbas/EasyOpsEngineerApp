// work_order_details_controller.dart
// ignore: file_names
import 'package:easy_ops/route_managment/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WorkOrderDetailsController extends GetxController {
  // Header
  final title = 'Work Order Details'.obs;

  // Operator
  final operatorName = ''.obs;
  final operatorInfo = ''.obs;
  final operatorPhoneNumber = ''.obs;

  // Banner
  final successTitle = 'Work Order Created\nSuccessfully'.obs;
  final successSub = 'Work Order ID - BD265'.obs;

  // Reporter / Operator (will be overridden from operator draft if present)
  final reportedBy = ''.obs;

  // Summary (from work order info)
  final descriptionText =
      ''.obs; // descriptionText (fallback: problemDescription)
  final priority = ''.obs; // impact
  final issueType = ''.obs; // issueType

  // Time / Date (from operator draft)
  final time = ''.obs; // HH:mm
  final date = ''.obs; // dd MMM

  // Location line under summary (you can join location + plant)
  final line = ''.obs; // keep for your own line text if needed
  final location = ''.obs; // "Location | Plant"

  // Body
  final headline = ''.obs; // typeText
  final problemDescription = ''.obs; // problemDescription

  // Media (from work order info)
  final photoPaths = <String>[].obs;
  final voiceNotePath = ''.obs;

  final cnc_1 = 'CNC-1'.obs;

  @override
  void onInit() {
    super.onInit();

    final box = GetStorage();

    /* ---------- 1) Load from Work Order Info draft ---------- */
    final woRaw = box.read('work_order_info_draft_v1');
    if (woRaw is Map) {
      final json = Map<String, dynamic>.from(woRaw);

      final String issueType = (json['issueType'] ?? '') as String;
      final String impact = (json['impact'] ?? '') as String;
      final String assetsNumber = (json['assetsNumber'] ?? '') as String;
      final String problemDesc = (json['problemDescription'] ?? '') as String;
      final String typeTextStr = (json['typeText'] ?? '-') as String;
      final String descTextStr = (json['descriptionText'] ?? '-') as String;

      // media
      final List<String> photos = (json['photos'] is List)
          ? (json['photos'] as List).map((e) => e.toString()).toList()
          : <String>[];
      final String voicePath = (json['voiceNotePath'] ?? '') as String;

      final String operatorName = (json['operatorName'] ?? '-') as String;
      final String operatorPhoneNumber =
          (json['operatorMobileNumber'] ?? '-') as String;
      final String operatorInfo = (json['operatorInfo'] ?? '-') as String;

      // map to observables

      this.operatorInfo.value = operatorInfo;
      this.operatorPhoneNumber.value = operatorPhoneNumber;
      this.operatorName.value = operatorName;

      this.issueType.value = issueType;
      priority.value = impact;
      headline.value = typeTextStr;
      problemDescription.value = problemDesc;
      descriptionText.value = descTextStr.isNotEmpty ? descTextStr : '-';

      photoPaths.assignAll(photos);
      voiceNotePath.value = voicePath;

      if (assetsNumber.isNotEmpty) {
        successSub.value = 'Asset: $assetsNumber';
      }
    }

    /* ---------- 2) Load from Operator Info draft ---------- */
    final opRaw = box.read('operator_info_draft_v1');
    if (opRaw is Map) {
      final json = Map<String, dynamic>.from(opRaw);

      final String reporter = (json['reporter'] ?? '') as String;
      final String operator = (json['operator'] ?? '') as String;
      final String employeeId = (json['employeeId'] ?? '-') as String;
      final String phone = (json['phoneNumber'] ?? '-') as String;
      final String locStr = (json['location'] ?? '') as String;
      final String plantStr = (json['plant'] ?? '') as String;
      final TimeOfDay? rt = _decodeTime(json['reportedTime'] as String?);
      final DateTime? rd = _decodeDate(json['reportedDate'] as String?);
      final String shiftStr = (json['shift'] ?? '') as String;

      // Reporter / Operator
      if (reporter.isNotEmpty) {
        reportedBy.value = reporter;
      }
      if (operator.isNotEmpty) {
        operatorName.value = operator;
      }

      // No explicit operator name saved in draft; best-effort using reporter + employeeId
      // final hasEmp = employeeId.trim().isNotEmpty && employeeId.trim() != '-';
      // operatorName.value = reporter.isNotEmpty
      //     ? (hasEmp ? '$reporter ($employeeId)' : reporter)
      //     : (hasEmp ? 'Employee ($employeeId)' : 'Operator');

      // operatorMobileNumber.value = phone;

      // Build org string like: "Assets Shop | Plant A | A"
      final parts = <String>[];
      if (locStr.isNotEmpty) parts.add(locStr);
      if (plantStr.isNotEmpty) parts.add(plantStr);
      if (shiftStr.isNotEmpty) parts.add(shiftStr);
      //operatorInfo.value = parts.join(' | ');

      // Show location line under summary (Location | Plant)
      final locParts = <String>[];
      if (locStr.isNotEmpty) locParts.add(locStr);
      if (plantStr.isNotEmpty) locParts.add(plantStr);
      location.value = locParts.join(' | ');

      // Time / Date formatting
      if (rt != null) time.value = _formatTime(rt);
      if (rd != null) date.value = _formatDate(rd);
    }

    // Fallbacks in case drafts were empty
    // reportedBy.value = reportedBy.value.isNotEmpty ? reportedBy.value : '—';
    // operatorName.value = operatorName.value.isNotEmpty
    //     ? operatorName.value
    //     : '—';
    // operatorMobileNumber.value = operatorMobileNumber.value.isNotEmpty
    //     ? operatorMobileNumber.value
    //     : '—';
    // operatorInfo.value = operatorInfo.value.isNotEmpty
    //     ? operatorInfo.value
    //     : '—';
    if (time.value.isEmpty) time.value = '—';
    if (date.value.isEmpty) date.value = '—';
    if (location.value.isEmpty) location.value = '—';
  }

  // --------- Helpers ---------

  TimeOfDay? _decodeTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  DateTime? _decodeDate(String? s) => s == null ? null : DateTime.tryParse(s);

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dd = d.day.toString().padLeft(2, '0');
    final mon = months[d.month - 1];
    return '$dd $mon';
  }

  void goToListing() => Get.offAllNamed(Routes.workOrderScreen);
}
