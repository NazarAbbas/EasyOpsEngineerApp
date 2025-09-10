// closure_page.dart
import 'dart:io';
import 'package:easy_ops/ui/modules/work_order_management/update_work_order/closure_work_order/controller/closure_work_order_controller.dart';
import 'package:easy_ops/utils/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class ClosureWorkOrderPage extends GetView<ClosureWorkOrderController> {
  const ClosureWorkOrderPage({super.key});

  @override
  ClosureWorkOrderController get controller =>
      Get.put(ClosureWorkOrderController());

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final hPad = isTablet ? 18.0 : 14.0;
    final headerH = isTablet ? 120.0 : 110.0;
    final btnH = isTablet ? 56.0 : 52.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: Obx(
          () => _GradientHeader(
            title: controller.pageTitle.value,
            isTablet: isTablet,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(btnH),
                    side: const BorderSide(color: _C.primary, width: 1.4),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: controller.reopenWorkOrder,
                  child: const Text(
                    'Re-open',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: // ...inside bottomNavigationBar -> FilledButton
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(btnH),
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                  ),
                  onPressed: () async {
                    await Get.showOverlay(
                      opacity: 0.35,
                      loadingWidget: const LoadingOverlay(
                        message: 'Closing Work Order...',
                      ),
                      asyncFunction: () => controller.closeWorkOrder(),
                    );
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
        child: Column(
          children: [
            _IssueHeaderCard(),
            const SizedBox(height: 12),
            _ClosureCommentsCard(),
            const SizedBox(height: 12),
            _SparesCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/* ===================== header ===================== */

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

/* ===================== top issue card ===================== */

class _IssueHeaderCard extends GetView<ClosureWorkOrderController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    controller.issueTitle.value,
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
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${controller.workOrderId.value}   ${controller.time.value} | ${controller.date.value}',
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
                      'In Progress',
                      style: TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(CupertinoIcons.time, size: 14, color: _C.muted),
                        SizedBox(width: 4),
                        Text(
                          '1h 20m',
                          style: TextStyle(
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

/* ===================== closure comments ===================== */

class _ClosureCommentsCard extends GetView<ClosureWorkOrderController> {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Closure Comments',
                style: TextStyle(
                  color: _C.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                ),
              ),
            ),
          ),

          const _KVLabel('Resolution Type'),
          const SizedBox(height: 6),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedResolution.value,
              items: controller.resolutionTypes
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (v) => controller.selectedResolution.value = v ?? '',
              decoration: _D.field(),
            ),
          ),

          const SizedBox(height: 16),
          const _KVLabel('Note'),
          const SizedBox(height: 6),
          TextField(
            controller: controller.noteCtrl,
            minLines: 3,
            maxLines: 6,
            decoration: _D.field(hint: 'Write your closure note'),
          ),

          const SizedBox(height: 16),
          const _KVLabel('Signature'),
          const SizedBox(height: 6),

          // Signature pad
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Signature(
                controller: controller.signatureCtrl,
                backgroundColor: const Color(0xFFF6F7FB),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: controller.clearSignature,
                icon: const Icon(CupertinoIcons.clear),
                label: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  final path = controller.savedSignaturePath.value;
                  if (path.isEmpty) return const SizedBox.shrink();

                  final f = File(path);
                  if (!f.existsSync()) return const SizedBox.shrink();

                  // show only the file name, ellipsized if too long
                  final fileName = f.path.split(Platform.pathSeparator).last;

                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Saved • $fileName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            '${TimeOfDay.now().format(context)} | Sept 30',
            style: const TextStyle(
              color: _C.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== spares ===================== */

class _SparesCard extends GetView<ClosureWorkOrderController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _Card(
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: controller.toggleSpares,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    const Text(
                      'Spares Consumed',
                      style: TextStyle(
                        color: _C.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '(${controller.totalQty} nos | ₹ ${controller.totalCost})',
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      controller.sparesExpanded.value
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 18,
                      color: _C.muted,
                    ),
                  ],
                ),
              ),
            ),
            if (controller.sparesExpanded.value) ...[
              const Divider(height: 1, color: _C.line),
              const SizedBox(height: 8),
              Column(
                children: controller.spares
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  color: _C.text,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${s.qty} nos',
                              style: const TextStyle(
                                color: _C.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '₹ ${s.unitPrice}',
                              style: const TextStyle(
                                color: _C.text,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/* ===================== small pieces ===================== */

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: child,
    );
  }
}

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

class _KVLabel extends StatelessWidget {
  final String text;
  const _KVLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _C.text,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}

/* ===================== styles ===================== */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}

class _D {
  static InputDecoration field({String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(color: _C.muted, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE1E6EF)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE1E6EF)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE1E6EF)),
      ),
    );
  }
}
