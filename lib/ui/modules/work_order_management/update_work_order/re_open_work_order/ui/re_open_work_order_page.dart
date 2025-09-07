import 'package:easy_ops/ui/modules/work_order_management/update_work_order/re_open_work_order/controller/re_open_work_order_controller.dart';
import 'package:easy_ops/utils/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReopenWorkOrderPage extends GetView<ReopenWorkOrderController> {
  const ReopenWorkOrderPage({super.key});

  @override
  ReopenWorkOrderController get controller =>
      Get.put(ReopenWorkOrderController());

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double headerH = isTablet ? 120 : 110;
    final double hPad = isTablet ? 18 : 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: _GradientHeader(title: 'Re-Open Work Order', isTablet: isTablet),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ------- Summary card
            _SummaryCard(),

            const SizedBox(height: 12),

            // ------- Form card
            _FormCard(),
          ],
        ),
      ),

      // ------- Footer actions
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _C.primary, width: 1.4),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: _C.primary,
                  ),
                  onPressed: controller.discard,
                  child: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ...
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    // (Optional) if you have a validate() method:
                    if (!controller.validate()) return;

                    await Get.showOverlay(
                      opacity: 0.35,
                      loadingWidget: const LoadingOverlay(
                        message: 'Re-opening Work Order...',
                      ),
                      asyncFunction: () => controller.reOpen(), // must be async
                    );
                  },
                  child: const Text(
                    'Re-Open',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────────────────────── Header ───────────────────────── */

class _GradientHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isTablet;
  const _GradientHeader({required this.title, required this.isTablet});

  @override
  Size get preferredSize => Size.fromHeight(isTablet ? 120 : 110);

  @override
  Widget build(BuildContext context) {
    final btnSize = isTablet ? 48.0 : 44.0;
    final iconSize = isTablet ? 26.0 : 22.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, isTablet ? 12 : 10, 12, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            SizedBox(
              width: btnSize,
              height: btnSize,
              child: IconButton(
                onPressed: Get.back,
                iconSize: iconSize,
                splashRadius: btnSize / 2,
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                tooltip: 'Back',
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: isTablet ? 20 : 18,
                ),
              ),
            ),
            SizedBox(width: btnSize, height: btnSize),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── Summary Card ───────────────────────── */

class _SummaryCard extends GetView<ReopenWorkOrderController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EEF5)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + priority pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    controller.summary.value,
                    style: const TextStyle(
                      color: _C.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _Pill(
                  text: controller.priority.value,
                  color: _priorityColor(controller.priority.value),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ID | time | date   +   status + duration
            Row(
              children: [
                Text(
                  controller.woId.value,
                  style: const TextStyle(
                    color: _C.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${controller.time.value} | ${controller.date.value}',
                  style: const TextStyle(
                    color: _C.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.status.value,
                      style: const TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.time_solid,
                          size: 14,
                          color: _C.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.duration.value,
                          style: const TextStyle(
                            color: _C.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              controller.category.value,
              style: const TextStyle(
                color: _C.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── Form Card ───────────────────────── */

class _FormCard extends GetView<ReopenWorkOrderController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Label(
            'Reason',
            _TapField(
              textObs: controller.selectedReason,
              placeholder: 'Select',
              onTap: () => _openReasonSheet(context),
            ),
          ),
          const SizedBox(height: 12),
          _Label(
            'Remark (Optional)',
            TextField(
              controller: controller.remarkCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: _D.field(hint: 'Add a remark...'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReasonSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Text(
                    'Select Reason',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _C.text,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(CupertinoIcons.xmark, size: 18),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _C.line),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.reasons.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFF2F5FA)),
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  title: Text(
                    controller.reasons[i],
                    style: const TextStyle(
                      color: _C.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    controller.selectedReason.value = controller.reasons[i];
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── Small pieces ───────────────────────── */

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String title;
  final Widget child;
  const _Label(this.title, this.child);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _C.text,
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final RxString textObs;
  final String placeholder;
  final VoidCallback onTap;
  const _TapField({
    required this.textObs,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEmpty = textObs.value.isEmpty;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: _D.field(
            suffix: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(CupertinoIcons.chevron_down, color: _C.muted),
            ),
          ),
          child: Text(
            isEmpty ? placeholder : textObs.value,
            style: TextStyle(
              color: isEmpty ? _C.muted : _C.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}

/* ───────────────────────── Style helpers ───────────────────────── */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}

class _D {
  static InputDecoration field({String? hint, Widget? prefix, Widget? suffix}) {
    return const InputDecoration(
      isDense: true,
      hintText: null,
      hintStyle: TextStyle(color: _C.muted, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      prefixIcon: null,
      suffixIcon: null,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: _C.line),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _C.line),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _C.line),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ).copyWith(hintText: hint, prefixIcon: prefix, suffixIcon: suffix);
  }
}

Color _priorityColor(String s) {
  switch (s.toLowerCase()) {
    case 'high':
      return const Color(0xFFEF4444);
    case 'medium':
      return const Color(0xFFF59E0B);
    case 'low':
      return const Color(0xFF10B981);
    default:
      return const Color(0xFF9CA3AF);
  }
}
