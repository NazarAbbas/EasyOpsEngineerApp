// sign_off_controller.dart
import 'dart:typed_data';
import 'package:easy_ops/ui/modules/maintenance_work_order/closure/ui/closure_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignOffController extends GetxController {
  // UI state
  final isSaving = false.obs;
  final hasSignature = false.obs;

  // Employee lookup
  final isSearching = false.obs;
  final empCode = ''.obs;
  final employee = Rxn<Employee>();
  final searchError = ''.obs;

  // Will hold the PNG bytes exported from the signature pad
  final signatureBytes = Rxn<Uint8List>();

  late final TextEditingController empCodeCtrl;
  late final Worker _debouncer;

  bool get canSave => hasSignature.value && employee.value != null;

  @override
  void onInit() {
    empCodeCtrl = TextEditingController();
    empCodeCtrl.addListener(() => empCode.value = empCodeCtrl.text.trim());

    // Debounce to avoid spammy lookups
    _debouncer = debounce<String>(
      empCode,
      (code) => code.length >= 3 ? lookupEmployee(code) : _clearLookup(),
      time: const Duration(milliseconds: 450),
    );
    super.onInit();
  }

  @override
  void onClose() {
    empCodeCtrl.dispose();
    _debouncer.dispose();
    super.onClose();
  }

  void clearSignature() {
    hasSignature.value = false;
    signatureBytes.value = null;
  }

  void _clearLookup() {
    employee.value = null;
    searchError.value = '';
  }

  Future<void> lookupEmployee(String code) async {
    isSearching.value = true;
    searchError.value = '';
    await Future.delayed(const Duration(milliseconds: 700)); // fake API

    // Mock directory
    const db = <String, Employee>{
      '1001': Employee(
        code: '1001',
        name: 'Rajesh Kumar',
        phone: '8979060058',
        department: 'Production',
        designation: 'Engineer',
      ),
      '1002': Employee(
        code: '1002',
        name: 'Ashwath Mahendran',
        phone: '9000012345',
        department: 'Maintenance',
        designation: 'Supervisor',
      ),
      'S1P12024': Employee(
        code: 'S1P12024',
        name: 'Rajesh Kumar',
        phone: '8979060058',
        department: 'Production',
        designation: 'Engineer',
      ),
    };

    final key = code.toUpperCase();
    if (db.containsKey(key)) {
      employee.value = db[key];
    } else {
      employee.value = null;
      searchError.value = 'No employee found for "$code".';
    }
    isSearching.value = false;
  }

  Future<void> save() async {
    if (!canSave || signatureBytes.value == null) return;
    isSaving.value = true;
    await Future.delayed(const Duration(seconds: 1)); // fake API
    isSaving.value = false;

    final emp = employee.value!;
    Get.back(
      result: SignatureResult(
        bytes: signatureBytes.value!, // <-- this is the pngBytes source
        name: emp.name,
        designation: emp.designation,
        time: DateTime.now(),
      ),
    );
  }
}

/* ───────── Models ───────── */

class Employee {
  final String code;
  final String name;
  final String phone;
  final String department;
  final String designation;

  const Employee({
    required this.code,
    required this.name,
    required this.phone,
    required this.department,
    required this.designation,
  });
}

/// Payload returned to the previous screen (e.g. Closure page)
// class SignatureResult {
//   final Uint8List bytes; // PNG bytes of the signature
//   final String name;
//   final String designation;
//   final DateTime time;

//   SignatureResult({
//     required this.bytes,
//     required this.name,
//     required this.designation,
//     required this.time,
//   });
// }
