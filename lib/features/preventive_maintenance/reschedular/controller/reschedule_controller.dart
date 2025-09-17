import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RescheduleController extends GetxController {
  // Header (mock/demo data — wire to your API if needed)
  final machineName = 'CNC-1'.obs;
  final brand = 'Siemens'.obs;
  final location = 'CNC Vertical Assets Center where we make housing'.obs;
  final severityText = 'Critical'.obs;
  final runningStatusText = 'Working'.obs;

  // Metrics (demo)
  final mtbf = '110 Days'.obs;
  final bdHours = '17 Hrs'.obs;
  final mttr = '2.4 Hrs'.obs;
  final criticality = 'Semi'.obs;

  // Preventive data (demo)
  final pendingHours = '4 Hrs required'.obs;
  final dueBy = DateTime(2024, 10, 30).obs;

  // Reason
  final reasons = <String>[
    'Operator Busy',
    'Material Not Available',
    'Changeover Planned',
    'Power Shutdown',
    'Other',
  ].obs;
  final selectedReason = RxnString();
  final noteCtrl = TextEditingController();

  // Option 1
  final opt1Date = Rxn<DateTime>();
  final opt1From = Rxn<TimeOfDay>();
  final opt1To = Rxn<TimeOfDay>();

  // Option 2
  final opt2Date = Rxn<DateTime>();
  final opt2From = Rxn<TimeOfDay>();
  final opt2To = Rxn<TimeOfDay>();

  // Derived: at least one complete option
  bool get _opt1Complete =>
      opt1Date.value != null && opt1From.value != null && opt1To.value != null;
  bool get _opt2Complete =>
      opt2Date.value != null && opt2From.value != null && opt2To.value != null;

  final isSubmitting = false.obs;
  bool get canSubmit => _opt1Complete || _opt2Complete;

  Future<void> pickDate({
    required int option,
    required BuildContext context,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: (option == 1 ? opt1Date.value : opt2Date.value) ?? now,
    );
    if (picked == null) return;
    if (option == 1) {
      opt1Date.value = picked;
    } else {
      opt2Date.value = picked;
    }
  }

  Future<void> pickTime({
    required int option,
    required bool isFrom,
    required BuildContext context,
  }) async {
    final initial = const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    if (option == 1) {
      if (isFrom) {
        opt1From.value = picked;
      } else {
        opt1To.value = picked;
      }
    } else {
      if (isFrom) {
        opt2From.value = picked;
      } else {
        opt2To.value = picked;
      }
    }
  }

  String fmtDate(DateTime? d) {
    if (d == null) return '__/__';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String fmtTime(TimeOfDay? t) {
    if (t == null) return '__:__';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  void discard() {
    Get.back<void>();
  }

  Future<void> submit() async {
    if (!canSubmit) {
      Get.snackbar(
        'Incomplete',
        'Provide at least one full option (date & time).',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isSubmitting.value = true;

    // TODO: wire to API
    await Future.delayed(const Duration(milliseconds: 700));

    isSubmitting.value = false;
    Get.back<void>();
    Get.snackbar(
      'Submitted',
      'Your proposal has been sent.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    noteCtrl.dispose();
    super.onClose();
  }
}
