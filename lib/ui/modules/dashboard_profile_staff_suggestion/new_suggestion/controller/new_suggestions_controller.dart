import 'package:easy_ops/route_managment/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// =================== CONTROLLER ===================

class NewSuggestionController extends GetxController {
  // Collapsible card
  final reporterExpanded = true.obs;

  // Reporter data (normally from auth/profile)
  final reporterName = 'Raj Kumar'.obs;
  final employeeCode = 'AS4512'.obs;
  final role = 'Worker'.obs;
  final reporterDept = 'Assets Shop'.obs;

  // Dropdown data
  final departments = <String>[
    'Banbury Department',
    'Assets Shop',
    'Maintenance',
    'Production',
  ];
  final types = <String>['Cost Saving', 'Quality', 'Safety', 'Process'];

  // Form state
  final formKey = GlobalKey<FormState>();
  final department = RxnString('Banbury Department');
  final type = RxnString('Cost Saving');

  final titleC = TextEditingController();
  final descriptionC = TextEditingController();
  final justificationC = TextEditingController();
  final amountC = TextEditingController(text: '100,000');

  @override
  void onClose() {
    titleC.dispose();
    descriptionC.dispose();
    justificationC.dispose();
    amountC.dispose();
    super.onClose();
  }

  void toggleReporter() => reporterExpanded.toggle();

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? validateTitle(String? v) => _req(v);
  String? validateDesc(String? v) => _req(v);
  String? validateJust(String? v) => _req(v);
  String? validateAmount(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  void submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if ((formKey.currentState?.validate() ?? false) &&
        department.value != null &&
        type.value != null) {
      // Build payload
      final payload = {
        'reportedBy': '${reporterName.value} (${employeeCode.value})',
        'role': role.value,
        'reporterDept': reporterDept.value,
        'department': department.value,
        'type': type.value,
        'title': titleC.text.trim(),
        'description': descriptionC.text.trim(),
        'justification': justificationC.text.trim(),
        'impactAmount': amountC.text.trim(),
      };
      // TODO: send to API
      Get.snackbar(
        'Submitted',
        'Your suggestion has been submitted successfully.',
        snackPosition: SnackPosition.TOP,
      );
      Get.toNamed(Routes.suggestionDetailsScreen);
      // debug print
      // print(payload);
    } else {
      Get.snackbar(
        'Missing info',
        'Please complete the required fields',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
