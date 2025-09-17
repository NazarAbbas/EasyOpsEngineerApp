import 'dart:async';
import 'package:easy_ops/features/maintenance_work_order/closure/controller/closure_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PendingActivityType { pmShutdownWeekend, breakdown, inspection }

// You can keep the other actions if you want, but we will only return `back`.
enum PendingActivityAction { added, updated, deleted, back }

extension _EnumName on Enum {
  String get name => toString().split('.').last;
}

class ActivityItem {
  final String id;
  final String title;
  final PendingActivityType type;
  final String? assignee;
  final DateTime? targetDate;
  final String? note;
  final String status;

  ActivityItem({
    required this.id,
    required this.title,
    required this.type,
    this.assignee,
    this.targetDate,
    this.note,
    this.status = 'In Progress',
  });

  ActivityItem copyWith({
    String? id,
    String? title,
    PendingActivityType? type,
    String? assignee,
    DateTime? targetDate,
    String? note,
    String? status,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      assignee: assignee ?? this.assignee,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }
}

/// ==== STRONGLY-TYPED RESULT (no Map) ====
class PendingActivityResult {
  final PendingActivityAction action; // will be PendingActivityAction.back
  final List<ActivityItem> activities;

  const PendingActivityResult({required this.action, required this.activities});
}

class PendingActivityController extends GetxController {
  final RxList<ActivityItem> activities = <ActivityItem>[].obs;

  // form fields
  final titleCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final Rx<PendingActivityType> selectedType =
      PendingActivityType.pmShutdownWeekend.obs;
  final RxString assignee = ''.obs;
  final Rx<DateTime?> targetDate = Rx<DateTime?>(null);

  // ui state
  final RxBool isSubmitting = false.obs;

  // editing state (null => adding new)
  final RxnInt editingIndex = RxnInt();

  final people = const ['Ramesh', 'Suresh', 'Priya', 'Aditi'];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PendingActivityArgs) {
      // Make a shallow copy so we don’t mutate caller’s list by reference
      activities.assignAll(List<ActivityItem>.from(args.initial));
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate.value ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) targetDate.value = picked;
  }

  String _newId() => 'AC-${300 + activities.length + 1}';

  Future<ActivityItem> _fakeCreate(ActivityItem item) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return item;
  }

  Future<ActivityItem> _fakeUpdate(ActivityItem item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return item;
  }

  bool get isEditing => editingIndex.value != null;

  void beginEdit(int index) {
    final a = activities[index];
    editingIndex.value = index;
    titleCtrl.text = a.title;
    noteCtrl.text = a.note ?? '';
    selectedType.value = a.type;
    assignee.value = a.assignee ?? '';
    targetDate.value = a.targetDate;
  }

  void cancelEdit() {
    editingIndex.value = null;
    _resetForm();
  }

  /// ---- Add / Update: modify list & stay on page (NO Get.back) ----
  Future<void> submit() async {
    final title = titleCtrl.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Missing Title',
        'Please enter Activity Title',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isSubmitting.value = true;

    try {
      if (isEditing) {
        final idx = editingIndex.value!;
        final existing = activities[idx];
        final updated = existing.copyWith(
          title: title,
          type: selectedType.value,
          assignee: assignee.value.isEmpty ? null : assignee.value,
          targetDate: targetDate.value,
          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        );
        final saved = await _fakeUpdate(updated);
        activities[idx] = saved;
        // (optional) bump edited item to top as in your other screen
        activities.removeAt(idx);
        activities.insert(0, saved);

        Get.snackbar(
          'Updated',
          'Activity updated',
          snackPosition: SnackPosition.BOTTOM,
        );
        cancelEdit();
        return;
      }

      // create
      final item = ActivityItem(
        id: _newId(),
        title: title,
        type: selectedType.value,
        assignee: assignee.value.isEmpty ? null : assignee.value,
        targetDate: targetDate.value,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );
      final created = await _fakeCreate(item);
      activities.insert(0, created);

      Get.snackbar(
        'Added',
        'Activity added',
        snackPosition: SnackPosition.BOTTOM,
      );

      _resetForm(); // stay on page
    } finally {
      isSubmitting.value = false;
    }
  }

  /// ---- Delete: modify list & stay on page (NO Get.back) ----
  void deleteAt(int index) {
    activities.removeAt(index);
    if (editingIndex.value == index) cancelEdit();
    Get.snackbar(
      'Deleted',
      'Activity removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ---- Save & Back / Back: RETURN TYPED RESULT ----
  void saveAndBack() {
    final result = PendingActivityResult(
      action: PendingActivityAction.back,
      activities: List<ActivityItem>.from(activities),
    );
    Get.back(result: result);
  }

  void _resetForm() {
    titleCtrl.clear();
    noteCtrl.clear();
    selectedType.value = PendingActivityType.pmShutdownWeekend;
    assignee.value = '';
    targetDate.value = null;
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
