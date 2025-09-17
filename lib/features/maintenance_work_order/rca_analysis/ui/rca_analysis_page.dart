import 'package:easy_ops/features/maintenance_work_order/rca_analysis/controller/rca_analysis_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RcaAnalysisPage extends GetView<RcaAnalysisController> {
  const RcaAnalysisPage({super.key});

  @override
  RcaAnalysisController get controller => Get.put(RcaAnalysisController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C4354),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Root Cause Analysis'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: Get.back,
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: const [
                    _SummaryCard(),
                    SizedBox(height: 12),
                    _ProblemCard(),
                    SizedBox(height: 12),
                    _FiveWhyCard(),
                    SizedBox(height: 12),
                    _CauseActionCard(),
                  ],
                ),
              ),
            ),
            if (controller.isSaving.value)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: Get.back,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: _C.primary, width: 1.2),
                    foregroundColor: _C.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final saving = controller.isSaving.value;
                  return FilledButton(
                    onPressed: saving ? null : controller.save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: _C.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save RCA',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────────────── Summary (top card) ──────────────── */

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + priority chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Latency Issue in web browser',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: _C.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7E7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'High',
                  style: TextStyle(
                    color: Color(0xFFED3B40),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text(
                'BD-102   18:08  |  09 Aug',
                style: TextStyle(color: _C.muted),
              ),
              Spacer(),
              Text(
                'Closed',
                style: TextStyle(color: _C.muted, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _Tag('Mechanical'),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CNC - 1 | ₹ 2000/hr',
                  style: TextStyle(
                    color: _C.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(CupertinoIcons.time, size: 18, color: _C.muted),
              SizedBox(width: 4),
              Text('3h 41m', style: TextStyle(color: _C.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

/* ───────────────── Problem Identified ──────────────── */

class _ProblemCard extends GetView<RcaAnalysisController> {
  const _ProblemCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Problem Identified',
            style: TextStyle(color: _C.muted, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.problemCtrl,
            minLines: 2,
            maxLines: 3,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter the problem.'
                : null,
            decoration: _input(),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── 5 Why Analysis ──────────────── */

class _FiveWhyCard extends GetView<RcaAnalysisController> {
  const _FiveWhyCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final open = controller.fiveWhyOpen.value;
            return Row(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      '5 Why Analysis',
                      style: TextStyle(
                        color: _C.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.fiveWhyOpen.toggle,
                  icon: Icon(
                    open
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: _C.muted,
                    size: 18,
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            return AnimatedCrossFade(
              crossFadeState: controller.fiveWhyOpen.value
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 180),
              firstChild: Column(
                children: List.generate(5, (i) {
                  return Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                    child: _WhyField(index: i + 1),
                  );
                }),
              ),
              secondChild: const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }
}

class _WhyField extends GetView<RcaAnalysisController> {
  final int index; // 1..5
  const _WhyField({required this.index});

  @override
  Widget build(BuildContext context) {
    final ctrl = controller.whyCtrls[index - 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why $index',
          style: const TextStyle(color: _C.muted, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          minLines: 2,
          maxLines: 3,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Please enter Why $index.'
              : null,
          decoration: _input(),
        ),
      ],
    );
  }
}

/* ───────────────── Root Cause + Corrective Action ──────────────── */

class _CauseActionCard extends GetView<RcaAnalysisController> {
  const _CauseActionCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Root Cause Identified'),
          TextFormField(
            controller: controller.rootCauseCtrl,
            minLines: 2,
            maxLines: 3,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter root cause.'
                : null,
            decoration: _input(),
          ),
          const SizedBox(height: 12),
          const _FieldLabel('Corrective Action'),
          TextFormField(
            controller: controller.correctiveCtrl,
            minLines: 2,
            maxLines: 3,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter corrective action.'
                : null,
            decoration: _input(),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── Smalls / Shared ──────────────── */

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(color: _C.muted, fontWeight: FontWeight.w800),
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(12)});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE9EEF5)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  const _SoftCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE9EEF5)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: child,
    ),
  );
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF4FF),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: const TextStyle(color: _C.primary, fontWeight: FontWeight.w700),
    ),
  );
}

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
}

InputDecoration _input() => InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: _C.primary, width: 1.2),
  ),
);
