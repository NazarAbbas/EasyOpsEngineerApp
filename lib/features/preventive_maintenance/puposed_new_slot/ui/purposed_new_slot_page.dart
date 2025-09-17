import 'package:easy_ops/features/preventive_maintenance/puposed_new_slot/controller/purposed_new_slot_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const text = Color(0xFF1F2430);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE9EEF5);
  static const danger = Color(0xFFED3B40);
}

class PurposedNewSlotPage extends GetView<PurposedNewSlotController> {
  const PurposedNewSlotPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    // Prefer binding/route injection in production; kept here for drop-in use.
    Get.put(PurposedNewSlotController(), permanent: false);

    final isTablet = _isTablet(context);
    final hPad = isTablet ? 20.0 : 14.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Get.back<void>(),
        ),
        title: const Text(
          'Propose New Slot',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 120),
        children: const [
          _MachineCard(),
          SizedBox(height: 12),
          _MetricsGrid(), // responsive => no horizontal overflow
          SizedBox(height: 12),
          _PreventiveCard(),
          SizedBox(height: 12),
          _ReasonCard(),
          SizedBox(height: 12),
          _OptionCard(optionIndex: 1),
          SizedBox(height: 12),
          _OptionCard(optionIndex: 2),
        ],
      ),
      bottomNavigationBar: Obx(() {
        // Read Rxs directly so Obx has dependencies
        final opt1Complete =
            controller.opt1Date.value != null &&
            controller.opt1From.value != null &&
            controller.opt1To.value != null;

        final opt2Complete =
            controller.opt2Date.value != null &&
            controller.opt2From.value != null &&
            controller.opt2To.value != null;

        final enabled = opt1Complete || opt2Complete;
        final kb = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: kb > 0 ? kb - 8 : 0,
          ), // lift above keyboard
          child: SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _C.border),
                        foregroundColor: _C.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: controller.discard,
                      child: const Text(
                        'Discard',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: enabled ? _C.primary : _C.border,
                        foregroundColor: enabled ? Colors.white : _C.muted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: controller.isSubmitting.value || !enabled
                          ? null
                          : controller.submit,
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/* ───────────────────────── Widgets ───────────────────────── */

class _MachineCard extends GetView<PurposedNewSlotController> {
  const _MachineCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    '${controller.machineName.value}  |  ${controller.brand.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const FittedBox(
                // protects if pill text ever grows
                child: _Pill(text: 'Critical', color: _C.danger),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  size: 18,
                  color: _C.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.location.value,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _C.text),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            controller.runningStatusText.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color == _C.danger
        ? const Color(0xFFFFEAEA)
        : const Color(0xFFEFF4FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

/* ------- Responsive metrics (grid prevents overflow) ------- */

class _MetricsGrid extends GetView<PurposedNewSlotController> {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final cols = w >= 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _metric('MTBF', controller.mtbf),
              _metric('BD Hours', controller.bdHours),
              _metric('MTTR', controller.mttr),
              _metric('Criticality', controller.criticality),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(String title, RxString value) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _C.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _C.muted, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value.value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _C.primary,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------- */

class _PreventiveCard extends GetView<PurposedNewSlotController> {
  const _PreventiveCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(
                  child: Text(
                    'Preventive',
                    style: TextStyle(
                      fontSize: 13,
                      color: _C.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 13,
                    color: _C.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Half Yearly Comprehensive\nMaintenance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Due by ${controller.fmtDate(controller.dueBy.value)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _C.text),
                  ),
                ),
                Text(
                  controller.pendingHours.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonCard extends GetView<PurposedNewSlotController> {
  const _ReasonCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Reason',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF3C4658),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Reason',
            style: TextStyle(fontWeight: FontWeight.w700, color: _C.text),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final value = controller.selectedReason.value;
            return _DropdownBox<String>(
              value: value,
              hint: 'Select',
              items: controller.reasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => controller.selectedReason.value = v,
            );
          }),
          const SizedBox(height: 14),
          const Text(
            'Note',
            style: TextStyle(fontWeight: FontWeight.w700, color: _C.text),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.noteCtrl,
            maxLines: 4,
            decoration: _inputDecoration(hint: ''),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends GetView<PurposedNewSlotController> {
  final int optionIndex; // 1 or 2
  const _OptionCard({required this.optionIndex});

  @override
  Widget build(BuildContext context) {
    final isFirst = optionIndex == 1;

    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              isFirst ? 'New Option 1' : 'New Option 2',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF3C4658),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Proposed Date',
            style: TextStyle(fontWeight: FontWeight.w700, color: _C.text),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final date = isFirst
                ? controller.opt1Date.value
                : controller.opt2Date.value;
            return _TappableBox(
              label: controller.fmtDate(date),
              icon: CupertinoIcons.calendar,
              onTap: () =>
                  controller.pickDate(option: optionIndex, context: context),
            );
          }),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _C.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      final t = isFirst
                          ? controller.opt1From.value
                          : controller.opt2From.value;
                      return _TappableBox(
                        label: controller.fmtTime(t),
                        icon: CupertinoIcons.time,
                        onTap: () => controller.pickTime(
                          option: optionIndex,
                          isFrom: true,
                          context: context,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _C.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      final t = isFirst
                          ? controller.opt1To.value
                          : controller.opt2To.value;
                      return _TappableBox(
                        label: controller.fmtTime(t),
                        icon: CupertinoIcons.time,
                        onTap: () => controller.pickTime(
                          option: optionIndex,
                          isFrom: false,
                          context: context,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Shared UI Helpers ───────────────────────── */

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _DropdownBox({
    super.key,
    this.value,
    required this.hint,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _inputDecoration(hint: hint),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
          icon: const Icon(CupertinoIcons.chevron_down),
        ),
      ),
    );
  }
}

class _TappableBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TappableBox({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: label.contains('__') ? _C.muted : _C.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: _C.muted),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String hint = ''}) => InputDecoration(
  hintText: hint.isEmpty ? null : hint,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _C.border),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _C.border),
  ),
);
