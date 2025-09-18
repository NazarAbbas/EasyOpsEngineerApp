import 'package:easy_ops/features/maintenance_work_order/hold_work_order/controller/hold_work_order_controller.dart';
import 'package:easy_ops/core/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ───────────────────────── Palette ─────────────────────────
class _C {
  static const bg = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const soft = Color(0xFFF6F7FB);
  static const border = Color(0xFFE9EEF5);
  static const text = Color(0xFF1F2430);
  static const muted = Color(0xFF7C8698);
  static const primary = Color(0xFF2F6BFF);
  static const pillBlue = Color(0xFFEFF4FF);
  static const dangerText = Color(0xFFED3B40);
  static const dangerBg = Color(0xFFFFE7E7);
}

/// ───────────────────────── Page ─────────────────────────
class HoldWorkOrderPage extends GetView<HoldWorkOrderController> {
  const HoldWorkOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Obx(
      () => Stack(
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
                'Hold Work Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: AbsorbPointer(
              absorbing: c.isSubmitting.value,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                children: [
                  _WoInfoCard(c),
                  const SizedBox(height: 12),
                  _HoldContextCard(c),
                  const SizedBox(height: 12),
                  _FormCard(c),
                ],
              ),
            ),
            bottomNavigationBar: _BottomBar(c),
          ),

          if (c.isSubmitting.value)
            const LoadingOverlay(message: 'Placing on hold…'),
        ],
      ),
    );
  }
}

/// ───────────────────────── Widgets ─────────────────────────
class _WoInfoCard extends StatelessWidget {
  const _WoInfoCard(this.c);
  final HoldWorkOrderController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  c.woTitle,
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
          const Align(
            alignment: Alignment.centerRight,
            child: _StatusPill(text: 'In Progress'),
          ),
          const SizedBox(height: 10),
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

class _HoldContextCard extends StatelessWidget {
  const _HoldContextCard(this.c);
  final HoldWorkOrderController c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration.copyWith(color: const Color(0xFFF9FAFC)),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    c.holdContextTitle.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.text,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_rounded,
                  color: _C.primary,
                  size: 20,
                ),
                onPressed: () => c.onEditContext(context),
                tooltip: 'Edit',
              ),
            ],
          ),
          Obx(
            () => Text(
              c.holdContextCategory.value,
              style: const TextStyle(
                color: _C.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              c.holdContextDesc.value,
              style: const TextStyle(color: _C.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard(this.c);
  final HoldWorkOrderController c;

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
      decoration: _cardDecoration.copyWith(color: const Color(0xFFF5F7FB)),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Hold Reasons',
                style: TextStyle(fontWeight: FontWeight.w700, color: _C.muted),
              ),
            ),
          ),

          // Hold Reason Title
          label('Hold Reason Title'),
          Obx(
            () => TextField(
              controller: c.reasonTitleCtrl,
              onChanged: (v) => c.reasonTitle.value = v,
              enabled: !c.isSubmitting.value,
              decoration: _inputDecoration(hint: 'Placeholder'),
            ),
          ),
          const SizedBox(height: 14),

          // Hold Reason Type (dropdown)
          label('Hold Reason Type'),
          Obx(
            () => _CupertinoLikeDropdown<String>(
              value: c.selectedReasonType.value,
              items: c.reasonTypes.toList(),
              onChanged: (v) {
                if (c.isSubmitting.value) return;
                HapticFeedback.selectionClick();
                c.selectedReasonType.value = v ?? c.reasonTypes.first;
              },
            ),
          ),
          const SizedBox(height: 14),

          // Remarks
          label('Remarks', optional: true),
          Obx(
            () => TextField(
              controller: c.remarksCtrl,
              minLines: 4,
              maxLines: 6,
              maxLength: 300,
              onChanged: (v) => c.remarks.value = v,
              enabled: !c.isSubmitting.value,
              textInputAction: TextInputAction.newline,
              decoration: _inputDecoration(
                hint: 'Type remarks…',
              ).copyWith(counterText: ''),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar(this.c);
  final HoldWorkOrderController c;

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
                  onPressed: c.isSubmitting.value ? null : () => c.onDiscard(),
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
                final canSubmit = c.canSubmit && !c.isSubmitting.value;
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
                          await c.onHold();
                        }
                      : null,
                  child: c.isSubmitting.value
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
                          'Hold Work Order',
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

/// ───────────────────────── Reusable UI helpers ─────────────────────────
InputDecoration _inputDecoration({required String hint}) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: _C.surface,
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
);

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
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

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(color: _C.muted, fontSize: 13.2));
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
        color: _C.surface,
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
