import 'package:easy_ops/core/utils/loading_overlay.dart' show LoadingOverlay;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:easy_ops/features/maintenance_work_order/reassign_work_order/controller/reassign_work_order_controller.dart';

/// Palette
class _C {
  static const bg = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const border = Color(0xFFE9EEF5);
  static const text = Color(0xFF1F2430);
  static const muted = Color(0xFF7C8698);
  static const primary = Color(0xFF2F6BFF);
  static const pillBlue = Color(0xFFEFF4FF);
  static const dangerText = Color(0xFFED3B40);
  static const dangerBg = Color(0xFFFFE7E7);
}

/// ───────────────────────── UI Page ─────────────────────────
class ReassignWorkOrderPage extends GetView<ReassignWorkOrderController> {
  const ReassignWorkOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Obx(() {
      // Stack allows us to show a full-screen progress overlay when submitting
      return Stack(
        children: [
          Scaffold(
            backgroundColor: _C.bg,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              toolbarHeight: 56,
              backgroundColor: primary,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: c.isSubmitting.value ? null : () => Get.back(),
              ),
              title: const Text(
                'Reassign Work Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            body: AbsorbPointer(
              absorbing: c.isSubmitting.value, // disable inputs while loading
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                children: [
                  _WoInfoCard(controller: c),
                  const SizedBox(height: 16),
                  _FormCard(controller: c),
                ],
              ),
            ),

            bottomNavigationBar: _BottomBar(controller: c),
          ),

          // ── Fullscreen progress overlay
          if (c.isSubmitting.value)
            const LoadingOverlay(message: 'Reassigning…'),
        ],
      );
    });
  }
}

/// ───────────────────────── Widgets ─────────────────────────
class _WoInfoCard extends StatelessWidget {
  const _WoInfoCard({required this.controller});
  final ReassignWorkOrderController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Priority
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  controller.woTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.text,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _PriorityChip(text: 'High'),
            ],
          ),
          const SizedBox(height: 8),

          // Right aligned status
          const Align(
            alignment: Alignment.centerRight,
            child: _StatusPill(text: 'In Progress'),
          ),
          const SizedBox(height: 10),

          // Meta line 1
          Row(
            children: const [
              _MutedText('BD-102'),
              _Dot(),
              _MutedText('18:08'),
              _Dot(),
              _MutedText('09 Aug'),
            ],
          ),
          const SizedBox(height: 8),

          // Meta line 2
          Row(
            children: const [
              Icon(Icons.apartment_rounded, size: 18, color: _C.muted),
              SizedBox(width: 6),
              _MutedText('Mechanical'),
              Spacer(),
              Icon(Icons.watch_later_outlined, size: 18, color: _C.muted),
              SizedBox(width: 6),
              _MutedText('1h 20m'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.controller});
  final ReassignWorkOrderController controller;

  @override
  Widget build(BuildContext context) {
    label(String s, {bool optional = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            s,
            style: const TextStyle(fontWeight: FontWeight.w700, color: _C.text),
          ),
          if (optional) ...[
            const SizedBox(width: 6),
            const Text('(Optional)', style: TextStyle(color: _C.muted)),
          ],
        ],
      ),
    );

    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label('Reason'),
          Obx(
            () => _CupertinoLikeDropdown<String>(
              value: controller.selectedReason.value,
              items: controller.reasons.toList(),
              onChanged: (v) {
                if (controller.isSubmitting.value)
                  return; // disable while submitting
                HapticFeedback.selectionClick();
                controller.selectedReason.value = v ?? controller.reasons.first;
              },
            ),
          ),
          const SizedBox(height: 16),

          label('Remarks', optional: true),
          _RemarksField(controller: controller),
          const SizedBox(height: 4),

          Obx(
            () => Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.remarks.value.length}/300',
                style: const TextStyle(fontSize: 12, color: _C.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});
  final ReassignWorkOrderController controller;

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: _C.surface,
          border: Border(top: BorderSide(color: _C.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          controller.onDiscard();
                        },
                  child: Text(
                    'Discard',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final canSubmit =
                    controller.selectedReason.value.isNotEmpty &&
                    !controller.isSubmitting.value;
                return FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: canSubmit
                        ? primary
                        : primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: canSubmit
                      ? () async {
                          HapticFeedback.mediumImpact();
                          await controller.onReassign(); // fake API
                        }
                      : null,
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Reassign',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// ───────────────────────── Mini Widgets ─────────────────────────
class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _C.dangerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _C.dangerText,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _C.pillBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _C.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: _C.muted, fontSize: 13.2));
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text('•', style: TextStyle(color: Color(0xFFB0B7C3))),
  );
}

final _cardDecoration = BoxDecoration(
  color: _C.surface,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: _C.border),
  boxShadow: const [
    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
  ],
);

class _CupertinoLikeDropdown<T> extends StatelessWidget {
  const _CupertinoLikeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    e.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, color: _C.text),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RemarksField extends StatelessWidget {
  const _RemarksField({required this.controller});
  final ReassignWorkOrderController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        controller: controller.remarksCtrl,
        minLines: 4,
        maxLines: 6,
        maxLength: 300,
        textInputAction: TextInputAction.newline,
        onChanged: (v) => controller.remarks.value = v,
        enabled: !controller.isSubmitting.value,
        decoration: InputDecoration(
          hintText: 'Type remarks…',
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF6F7FB),
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBFD0FF)),
          ),
        ),
      ),
    );
  }
}
