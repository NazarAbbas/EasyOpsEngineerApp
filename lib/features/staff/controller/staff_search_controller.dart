// staff_search_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// -----------------------------
/// Controller
/// -----------------------------
class StaffSearchController extends GetxController {
  // Text query
  final queryCtrl = TextEditingController();

  // Options (replace with API data if needed)
  final locations = <String>[
    'Plant A, Roorkee',
    'Plant B, Haridwar',
    'Plant C, Dehradun',
  ].obs;

  final shifts = <String>['Shift A', 'Shift B', 'Shift C'].obs;

  final departments = <String>[
    'Assets Shop',
    'Mechanical',
    'Maintenance',
    'Production',
  ].obs;

  final functions = <String>[
    'Electrical',
    'Mechanical',
    'Instrumentation',
    'Utilities',
  ].obs;

  // Selected values
  final RxnString location = RxnString('Plant A, Roorkee');
  final RxnString shift = RxnString('Shift A');
  final RxnString department = RxnString('Assets Shop');
  final RxnString func = RxnString('Electrical');
  final date = DateTime.now().obs;

  String get dateLabel {
    final d = date.value;
    final today = DateTime.now();
    final sameDay =
        d.year == today.year && d.month == today.month && d.day == today.day;
    final base = DateFormat('dd/MM/yyyy').format(d);
    return sameDay ? '$base (Today)' : base;
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date.value,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      helpText: 'Select Date',
      builder: (context, child) {
        // Compact date picker text on phones
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) date.value = picked;
  }

  void submit() {
    // TODO: hook your API here
    Get.snackbar(
      'Searching…',
      'Query: "${queryCtrl.text}"\n'
          'Location: ${location.value}\n'
          'Shift: ${shift.value}\n'
          'Date: ${dateLabel}\n'
          'Department: ${department.value}\n'
          'Function: ${func.value}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    queryCtrl.dispose();
    super.onClose();
  }
}
