import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:easy_ops/ui/modules/work_order_management/create_work_order/tabs/controller/work_tabs_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OperatorInfoController extends GetxController {
  // Storage
  final sameAsOperator = false.obs;
  static const _draftKey = 'operator_info_draft_v1';
  final _box = GetStorage();
  late final List<Worker> _workers;

  // Reporter
  final operatorCtrl = TextEditingController();
  final reporterCtrl = TextEditingController();
  final employeeId = '-'.obs;
  final phoneNumber = '-'.obs;

  // Location & shift
  final location = ''.obs;
  final plant = ''.obs;
  final reportedTime = Rxn<TimeOfDay>();
  final reportedDate = Rxn<DateTime>();
  final shift = ''.obs;

  // Options
  final locations = const ['Assets Shop', 'Assembly', 'Bay 1', 'Bay 3'];
  final plantsOpt = const ['Plant A', 'Plant B', 'Plant C'];
  final shiftsOpt = const ['A', 'B', 'C'];

  // ----- UI helpers used by the page (read-only) -----
  String get timeText {
    final t = reportedTime.value;
    if (t == null) return 'hh:mm';
    final h = t.hourOfPeriod.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  String get dateText {
    final d = reportedDate.value;
    if (d == null) return 'dd/mm/yyyy';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  // ===== Lifecycle =====
  @override
  void onInit() {
    super.onInit();
    _loadDraft();
    _setupAutosave();
  }

  @override
  void onClose() {
    for (final w in _workers) {
      w.dispose();
    }
    reporterCtrl.dispose();
    operatorCtrl.dispose();
    super.onClose();
  }

  // ===== Draft persistence =====
  void _setupAutosave() {
    // Save when any Rx changes
    _workers = [
      ever<String>(employeeId, (_) => saveDraft()),
      ever<String>(phoneNumber, (_) => saveDraft()),
      ever<String>(location, (_) => saveDraft()),
      ever<String>(plant, (_) => saveDraft()),
      ever<TimeOfDay?>(reportedTime, (_) => saveDraft()),
      ever<DateTime?>(reportedDate, (_) => saveDraft()),
      ever<String>(shift, (_) => saveDraft()),
    ];
    // Save when reporter text changes
    reporterCtrl.addListener(saveDraft);
    operatorCtrl.addListener(saveDraft);
  }

  Map<String, dynamic> _payload() => {
    'reporter': reporterCtrl.text,
    'operator': operatorCtrl.text,
    'employeeId': employeeId.value,
    'phoneNumber': phoneNumber.value,
    'location': location.value,
    'plant': plant.value,
    'reportedTime': _encodeTime(reportedTime.value), // "HH:mm"
    'reportedDate': _encodeDate(reportedDate.value), // ISO
    'shift': shift.value,
  };

  void saveDraft() {
    _box.write(_draftKey, _payload());
  }

  void _loadDraft() {
    final raw = _box.read(_draftKey);
    if (raw is! Map) return;
    final json = Map<String, dynamic>.from(raw);

    reporterCtrl.text = (json['reporter'] ?? '') as String;
    operatorCtrl.text = (json['operator'] ?? '') as String;
    employeeId.value = (json['employeeId'] ?? '-') as String;
    phoneNumber.value = (json['phoneNumber'] ?? '-') as String;

    location.value = (json['location'] ?? '') as String;
    plant.value = (json['plant'] ?? '') as String;

    reportedTime.value = _decodeTime(json['reportedTime'] as String?);
    reportedDate.value = _decodeDate(json['reportedDate'] as String?);

    shift.value = (json['shift'] ?? '') as String;
  }

  void _clearDraft() => _box.remove(_draftKey);

  // ===== Public actions =====
  void discard() {
    reporterCtrl.clear();
    operatorCtrl.clear();
    employeeId.value = '-';
    phoneNumber.value = '-';
    location.value = '';
    plant.value = '';
    reportedTime.value = null;
    reportedDate.value = null;
    shift.value = '';

    _clearDraft();

    Get.snackbar(
      'Discarded',
      'All fields cleared.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryBlue,
      colorText: AppColors.white,
    );
  }

  void saveAndBack() {
    saveDraft();
    Get.snackbar(
      'Saved',
      'Operator info saved.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: AppColors.text,
    );
    Get.find<WorkTabsController>().goTo(0);
    // Get.back();
  }

  // ===== Encoding helpers =====
  String? _encodeTime(TimeOfDay? t) => t == null
      ? null
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _decodeTime(String? s) {
    if (s == null || s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String? _encodeDate(DateTime? d) => d?.toIso8601String();

  DateTime? _decodeDate(String? s) => s == null ? null : DateTime.tryParse(s);
}
