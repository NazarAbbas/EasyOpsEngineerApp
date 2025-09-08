import 'package:easy_ops/ui/modules/maintenance_work_order/return_spare_parts/controller/return_spare_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnSparesPage extends GetView<ReturnSparesController> {
  const ReturnSparesPage({super.key});

  @override
  ReturnSparesController get controller => Get.put(ReturnSparesController());

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Return Spares',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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
              child: _SoftCard(
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Part No.',
                            style: TextStyle(
                              color: _C.muted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Returns',
                          style: TextStyle(
                            color: _C.muted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...controller.items.map((e) => _SpareRow(item: e)).toList(),
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
                  onPressed: controller.onDiscard,
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
                  return FilledButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.onReturn,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: _C.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Return',
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

/* ───────────────────────── Row Widget ───────────────────────── */

class _SpareRow extends GetView<ReturnSparesController> {
  final SpareItem item;
  const _SpareRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EEF5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // Part details
          Expanded(child: _PartLabel(item: item)),
          const SizedBox(width: 12),
          // Stepper
          Obx(() {
            final canDec = item.returning.value > 0;
            final canInc = item.returning.value < item.requested;
            return _SegmentStepper(
              valueText: item.returning.value.toString().padLeft(2, '0'),
              onMinus: canDec ? () => controller.dec(item) : null,
              onPlus: canInc ? () => controller.inc(item) : null,
            );
          }),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _PartLabel extends StatelessWidget {
  final SpareItem item;
  const _PartLabel({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name (bold)
        Text(
          item.name,
          style: const TextStyle(
            color: _C.text,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 2),
        // Code (semi-muted)
        Text(
          item.code,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        // requested note
        Text(
          '${item.requested.toString().padLeft(2, '0')} nos requested',
          style: const TextStyle(
            color: _C.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/* ───────────────────────── Fancy Stepper ───────────────────────── */

class _SegmentStepper extends StatelessWidget {
  final String valueText;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  const _SegmentStepper({required this.valueText, this.onMinus, this.onPlus});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    const borderColor = Color(0xFFE2E8F0);

    Widget btn(IconData icon, VoidCallback? onTap, {BorderRadius? r}) {
      final enabled = onTap != null;
      return InkWell(
        onTap: onTap,
        borderRadius: r ?? radius,
        child: Container(
          width: 42,
          height: 40,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF8FAFF) : const Color(0xFFF3F4F6),
            borderRadius: r ?? radius,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: enabled ? _C.text : _C.muted),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            CupertinoIcons.minus,
            onMinus,
            r: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          Container(
            width: 54,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: borderColor),
                right: BorderSide(color: borderColor),
              ),
              color: Colors.white,
            ),
            child: Text(
              valueText,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _C.text,
              ),
            ),
          ),
          btn(
            CupertinoIcons.plus,
            onPlus,
            r: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Shared UI ───────────────────────── */

class _SoftCard extends StatelessWidget {
  final Widget child;
  const _SoftCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE9EEF5)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: child,
    ),
  );
}

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
}
