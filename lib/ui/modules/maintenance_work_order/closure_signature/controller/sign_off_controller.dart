// sign_off_controller.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ===== Typed payload returned to the previous screen (e.g., Closure page)
class SignatureResult {
  final Uint8List?
  bytes; // PNG bytes of the signature (nullable until user signs)
  final String name; // resolved from employee directory
  final String designation; // resolved from employee directory
  final String empCode; // what the user entered / selected
  final DateTime time; // when the signature was captured

  const SignatureResult({
    required this.bytes,
    required this.name,
    required this.designation,
    required this.empCode,
    required this.time,
  });

  factory SignatureResult.empty() => SignatureResult(
    bytes: null,
    name: '',
    designation: '',
    empCode: '',
    time: DateTime.now(),
  );

  SignatureResult copyWith({
    Uint8List? bytes,
    String? name,
    String? designation,
    String? empCode,
    DateTime? time,
  }) {
    return SignatureResult(
      bytes: bytes ?? this.bytes,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      empCode: empCode ?? this.empCode,
      time: time ?? this.time,
    );
  }
}

/// Example directory entry
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

class SignOffController extends GetxController {
  // UI state
  final isSaving = false.obs;
  final hasSignature = false.obs;

  // Employee lookup
  final isSearching = false.obs;
  final empCode = ''.obs;
  final employee = Rxn<Employee>();
  final searchError = ''.obs;

  // Signature bytes (from canvas or initial)
  final signatureBytes = Rxn<Uint8List>();

  // Text controllers
  late final TextEditingController empCodeCtrl;

  // Debouncer (from GetX)
  late final Worker _debouncer;

  // Prefill (incoming) model
  late final SignatureResult _initial;

  bool get canSave => hasSignature.value && employee.value != null;

  @override
  void onInit() {
    super.onInit();

    // 1) Read typed arguments to prefill screen
    final arg = Get.arguments;
    _initial = (arg is SignatureResult) ? arg : SignatureResult.empty();

    empCodeCtrl = TextEditingController(text: _initial.empCode);
    empCode.value = empCodeCtrl.text.trim();

    // Prefill signature preview if provided
    signatureBytes.value = _initial.bytes;
    hasSignature.value = _initial.bytes != null;

    // If we already have an emp code, try to resolve it immediately
    if (empCode.value.length >= 3) {
      // fire-and-forget; no await in onInit
      lookupEmployee(empCode.value);
    }

    // 2) Listen for emp code input changes
    empCodeCtrl.addListener(() => empCode.value = empCodeCtrl.text.trim());

    // 3) Debounce for lookups
    _debouncer = debounce<String>(
      empCode,
      (code) => code.length >= 3 ? lookupEmployee(code) : _clearLookup(),
      time: const Duration(milliseconds: 450),
    );
  }

  @override
  void onClose() {
    empCodeCtrl.dispose();
    _debouncer.dispose();
    super.onClose();
  }

  /* ───────── Signature handling ───────── */

  void setSignature(Uint8List bytes) {
    signatureBytes.value = bytes;
    hasSignature.value = true;
  }

  void clearSignature() {
    hasSignature.value = false;
    signatureBytes.value = null;
  }

  /* ───────── Lookup handling ───────── */

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

  /* ───────── Save & Back (return typed model) ───────── */

  Future<void> save() async {
    // guard clauses
    if (signatureBytes.value == null) {
      Get.snackbar(
        'Signature required',
        'Please add a signature first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (employee.value == null) {
      Get.snackbar(
        'Employee not found',
        'Please enter a valid Employee Code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 800)); // fake API
    isSaving.value = false;

    final emp = employee.value!;
    final result = SignatureResult(
      bytes: signatureBytes.value, // png bytes
      name: emp.name,
      designation: emp.designation,
      empCode: emp.code,
      time: DateTime.now(),
    );

    Get.back(result: result);
  }
}
