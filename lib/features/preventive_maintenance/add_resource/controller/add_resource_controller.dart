import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddedResource {
  final String name; // e.g., PM-402
  final String type; // e.g., Hydra
  final String? assignee; // e.g., Ramesh Chand
  final DateTime? targetDate; // optional
  final String? note; // optional

  AddedResource({
    required this.name,
    required this.type,
    this.assignee,
    this.targetDate,
    this.note,
  });
}

class AddResourceController extends GetxController {
  // Location shown in the added-row (to mimic your default row look)
  final location = 'CNC Vertical Assets Center where we make housing'.obs;

  // Top list (starts empty — no default row)
  final added = <AddedResource>[].obs;

  // Form state
  final nameCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  // Make name reactive so the button enables while typing
  final nameRx = ''.obs;

  final resourceTypes = <String>[
    'Hydra',
    'External Man Power',
    'Stamping',
    'Fixture',
    'Tooling',
  ].obs;
  final selectedType = RxnString(); // start null

  final assignees = <String>[
    'Ramesh Chand',
    'Asha S',
    'Vivek Rao',
    'Anil Kumar',
  ].obs;
  final selectedAssignee = RxnString(); // optional

  final targetDate = Rxn<DateTime>(); // optional

  final isSubmitting = false.obs;

  // States for bottom button
  bool get canAdd =>
      nameRx.value.trim().isNotEmpty && selectedType.value != null;

  bool get canSubmit => added.isNotEmpty && !isSubmitting.value;

  String fmtDate(DateTime? d) {
    if (d == null) return 'DD/MM/YYYY';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: targetDate.value ?? now,
    );
    if (picked != null) targetDate.value = picked;
  }

  // Add -> put into list (top), clear form, button switches to Submit
  Future<void> addToList() async {
    if (!canAdd) {
      Get.snackbar(
        'Missing info',
        'Please fill Name and Resource Type.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final item = AddedResource(
      name: nameRx.value.trim(),
      type: selectedType.value!,
      assignee: selectedAssignee.value,
      targetDate: targetDate.value,
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
    );

    added.insert(0, item);

    // Clear form + focus
    nameCtrl.clear();
    nameRx.value = '';
    selectedType.value = null;
    selectedAssignee.value = null;
    targetDate.value = null;
    noteCtrl.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void removeAt(int index) {
    if (index >= 0 && index < added.length) {
      added.removeAt(index);
    }
  }

  // Submit -> send entire `added` list to your API
  Future<void> submit() async {
    if (!canSubmit) return;
    isSubmitting.value = true;

    // TODO: Replace with your API call using `added`
    await Future.delayed(const Duration(milliseconds: 700));

    isSubmitting.value = false;
    Get.back<void>();
    Get.snackbar(
      'Saved',
      'Resources submitted successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
