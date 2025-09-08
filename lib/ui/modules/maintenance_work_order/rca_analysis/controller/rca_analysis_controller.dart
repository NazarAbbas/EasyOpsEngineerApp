import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RcaResult {
  final String problemIdentified;
  final List<String> fiveWhys; // length = 5
  final String rootCause;
  final String correctiveAction;

  const RcaResult({
    required this.problemIdentified,
    required this.fiveWhys,
    required this.rootCause,
    required this.correctiveAction,
  });
}

class RcaAnalysisController extends GetxController {
  // UI state
  final isSaving = false.obs;
  final fiveWhyOpen = true.obs;

  // Form controllers
  late final TextEditingController problemCtrl;
  late final List<TextEditingController> whyCtrls; // 5 items
  late final TextEditingController rootCauseCtrl;
  late final TextEditingController correctiveCtrl;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    problemCtrl = TextEditingController();
    whyCtrls = List.generate(5, (_) => TextEditingController());
    rootCauseCtrl = TextEditingController();
    correctiveCtrl = TextEditingController();

    // (Optional demo defaults)
    problemCtrl.text = 'Vehicle will not start';
    whyCtrls[0].text = 'The Battery is dead';
    whyCtrls[1].text = 'The alternator is not functioning';
    whyCtrls[2].text = 'The alternator belt has broken';
    whyCtrls[3].text =
        'The alternator belt was well beyond its useful service life and replaced.';
    whyCtrls[4].text =
        'The vehicle was not maintained according to the recommended service schedule.';
    rootCauseCtrl.text = 'Service Scheduled not followed';
    correctiveCtrl.text =
        'Ensure 100% schedule adherence of preventive maintenance';
    super.onInit();
  }

  @override
  void onClose() {
    problemCtrl.dispose();
    for (final c in whyCtrls) c.dispose();
    rootCauseCtrl.dispose();
    correctiveCtrl.dispose();
    super.onClose();
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 800)); // fake API
    isSaving.value = false;

    final result = RcaResult(
      problemIdentified: problemCtrl.text.trim(),
      fiveWhys: whyCtrls.map((e) => e.text.trim()).toList(growable: false),
      rootCause: rootCauseCtrl.text.trim(),
      correctiveAction: correctiveCtrl.text.trim(),
    );

    Get.back(result: result);
  }
}
