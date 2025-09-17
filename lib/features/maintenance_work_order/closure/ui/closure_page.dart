import 'dart:typed_data';

import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/maintenance_work_order/closure/controller/closure_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/closure_signature/controller/sign_off_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/pending_activity/controller/pending_activity_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/rca_analysis/controller/rca_analysis_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClosurePage extends GetView<ClosureController> {
  const ClosurePage({super.key});

  @override
  ClosureController get controller => Get.put(ClosureController());

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Closure',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: const [
                  _SummaryCard(),
                  SizedBox(height: 12),
                  _ClosureCommentsCard(),
                  SizedBox(height: 12),
                  _SparesConsumedCard(),
                  SizedBox(height: 12),
                  _RcaCard(),
                  SizedBox(height: 12),
                  _PendingActivityCard(),
                ],
              ),
            ),
            if (controller.isLoading.value)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      }),
      bottomNavigationBar: _BottomBar(onResolve: controller.resolveWorkOrder),
    );
  }
}

/* ─────────────────────── BOTTOM BAR ─────────────────────── */

class _BottomBar extends GetView<ClosureController> {
  final VoidCallback onResolve;
  const _BottomBar({required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: PopupMenuButton<String>(
                onSelected: (v) => Get.snackbar('Action', v),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'Hold Work Order',
                    child: Text('Hold Work Order'),
                  ),
                  PopupMenuItem(
                    value: 'Reassign Work Order',
                    child: Text('Reassign Work Order'),
                  ),
                  PopupMenuItem(
                    value: 'Cancel Work Order',
                    child: Text('Cancel Work Order'),
                  ),
                ],
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Other Options',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 6),
                      Icon(CupertinoIcons.chevron_up, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final loading = controller.isLoading.value;
                return FilledButton(
                  onPressed: loading ? null : onResolve,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 1.5,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Resolve Work Order',
                          style: TextStyle(fontWeight: FontWeight.w800),
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

/* ───────────── Summary (hero-ish top card) ───────────── */

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
            children: const [
              Expanded(
                child: Text(
                  'Latency Issue in web browser',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ),
              _PriorityPill(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text(
                'BD-102   18:08  |  09 Aug',
                style: TextStyle(
                  color: Color(0xFF7C8698),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Text(
                'In Progress',
                style: TextStyle(
                  color: Color(0xFF2F6BFF),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _Tag('Mechanical'),
              SizedBox(width: 8),
              Icon(CupertinoIcons.link, size: 18, color: Color(0xFF2F6BFF)),
              Spacer(),
              Icon(CupertinoIcons.time, size: 18, color: Color(0xFF7C8698)),
              SizedBox(width: 4),
              Text('1h 20m', style: TextStyle(color: Color(0xFF7C8698))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE7E7),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Text(
      'High',
      style: TextStyle(color: Color(0xFFED3B40), fontWeight: FontWeight.w800),
    ),
  );
}

/* ───────────── Closure Comments (form + signature) ───────────── */

class _ClosureCommentsCard extends GetView<ClosureController> {
  const _ClosureCommentsCard();

  String _fmt(DateTime dt) {
    final hRaw = dt.hour % 12;
    final h = hRaw == 0 ? 12 : hRaw;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$h:$mm $ampm | ${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Closure Comments'),
          const SizedBox(height: 12),

          const Text(
            'Resolution Type',
            style: TextStyle(color: _C.muted, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.selectedResolution.value,
              items: controller.resolutionTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => controller.selectedResolution.value =
                  v ?? controller.selectedResolution.value,
              decoration: _borderInputDecoration(),
            );
          }),

          const SizedBox(height: 14),
          const Text(
            'Add Note (Optional)',
            style: TextStyle(color: _C.muted, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.noteController,
            maxLines: 4,
            decoration: _borderInputDecoration().copyWith(
              hintText: 'Type here...',
            ),
          ),

          const SizedBox(height: 16),

          // Signature area (reactive to controller.signatureResult)
          Obx(() {
            final sig = controller.signatureResult.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // preview + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SignatureBox(bytes: sig?.bytes),
                      const SizedBox(height: 6),
                      if (sig != null) ...[
                        Text(
                          _fmt(sig.time),
                          style: const TextStyle(color: _C.muted, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${sig.name} | ${sig.designation}',
                          style: const TextStyle(color: _C.muted, fontSize: 12),
                        ),
                      ] else
                        const Text(
                          'Tap the pencil to add a signature',
                          style: TextStyle(color: _C.muted, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _IconChip(
                  icon: CupertinoIcons.pencil_ellipsis_rectangle,
                  bg: const Color(0xFFEFF4FF),
                  fg: _C.primary,
                  dimension: 56,
                  iconSize: 26,
                  tooltip: 'Edit signature',
                  onTap: () async {
                    final res = await Get.toNamed(
                      Routes.signOffScreen,
                      arguments:
                          controller.signatureResult.value ??
                          SignatureResult.empty(),
                    );
                    if (res is SignatureResult) {
                      controller.signatureResult.value = res;
                    }
                  },
                  // onTap: () async {
                  // final res = await Get.toNamed(Routes.signOffScreen);
                  //controller.signatureResult.value = res;
                  // },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/* ───────────── Spares Consumed (accordion) ───────────── */

class _SparesConsumedCard extends GetView<ClosureController> {
  const _SparesConsumedCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final open = controller.sparesOpen.value;
      final totalNos = controller.sparesConsumedNos.value;
      final totalCost = controller.sparesConsumedCost.value;

      return _SoftCard(
        child: Column(
          children: [
            _AccordionHeader(
              title: 'Spares Consumed',
              subtitle: '($totalNos nos | ₹ $totalCost)',
              open: open,
              onToggle: () => controller.sparesOpen.toggle(),
            ),
            AnimatedCrossFade(
              crossFadeState: open
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 180),
              firstChild: Column(
                children: [
                  const Divider(color: _C.line, height: 20),
                  _KVRow(
                    leftTitle: 'Spares Consumed',
                    leftValue: '${controller.sparesConsumedNos.value} nos',
                    rightTitle: 'Cost',
                    rightValue: '₹ ${controller.sparesConsumedCost.value}',
                  ),
                  const SizedBox(height: 12),
                  _KVRow(
                    leftTitle: 'Spares Issued',
                    leftValue: '${controller.sparesIssuedNos.value} nos',
                    rightTitle: 'Cost',
                    rightValue: '₹ ${controller.sparesIssuedCost.value}',
                  ),
                  const SizedBox(height: 12),
                  _KVRow(
                    leftTitle: 'Spares to be Returned',
                    leftValue: '${controller.sparesToReturnNosTotal} nos',
                    rightTitle: 'Cost',
                    rightValue: controller.sparesToReturnCostTotal == 0
                        ? '₹ -'
                        : '₹ ${controller.sparesToReturnCostTotal}',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Need to return spares?',
                          style: TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      // _SparesConsumedCard onTap for return spares
                      _IconChip(
                        icon: CupertinoIcons.wrench_fill,
                        bg: const Color(0xFFEFF4FF),
                        fg: _C.primary,
                        onTap: () async {
                          // Navigate with current list as initial value
                          final res = await Get.toNamed(
                            Routes.returnSpareScreen,
                            arguments: List<SpareReturnItem>.from(
                              controller.sparesToReturn,
                            ),
                          );

                          // Expect the next page to return `List<SpareReturnItem>`
                          if (res is List<SpareReturnItem>) {
                            controller.sparesToReturn.assignAll(res);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap; // 👈 add this
  final double dimension;
  final double iconSize;
  final String? tooltip;

  const _IconChip({
    required this.icon,
    required this.bg,
    required this.fg,
    this.onTap, // 👈 and this
    this.dimension = 48,
    this.iconSize = 22,
    this.tooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    final content = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: fg),
    );
    final child = tooltip == null
        ? content
        : Tooltip(message: tooltip!, child: content);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // 👈 handle tap
        borderRadius: radius,
        child: child,
      ),
    );
  }
}

/* ───────────── RCA Summary (accordion) ───────────── */

class _RcaCard extends GetView<ClosureController> {
  const _RcaCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final open = controller.rcaOpen.value;
      final r = controller.rcaResult.value; // this may be null
      return _SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionHeader(
              title: 'Root Cause Analysis (Summary)',
              open: open,
              onToggle: () => controller.rcaOpen.toggle(),
            ),
            AnimatedCrossFade(
              crossFadeState: open
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 180),
              firstChild: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _RcaLine('Problem Identified', r?.problemIdentified),

                    const SizedBox(height: 10),
                    _RcaLine('Why 1', r?.fiveWhys[0]),
                    const SizedBox(height: 10),
                    _RcaLine('Why 2', r?.fiveWhys[1]),
                    const SizedBox(height: 10),
                    _RcaLine('Why 3', r?.fiveWhys[2]),
                    const SizedBox(height: 10),
                    _RcaLine('Why 4', r?.fiveWhys[3]),
                    const SizedBox(height: 10),
                    _RcaLine('Why 5', r?.fiveWhys[4]),
                    const SizedBox(height: 10),
                    _RcaLine('Root Cause Identified', r?.rootCause),
                    const SizedBox(height: 10),
                    _RcaLine('Corrective Action', r?.correctiveAction),
                    const SizedBox(height: 16),
                    const _EnterRowRCA(
                      text: 'Enter Root Cause Analysis',
                      icon: CupertinoIcons.search,
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}

class _RcaLine extends StatelessWidget {
  final String title;
  final String? value; // <- nullable
  final String placeholder;

  const _RcaLine(
    this.title,
    this.value, {
    this.placeholder = '-', // shown when null/empty
  });

  @override
  Widget build(BuildContext context) {
    final display = (value?.trim().isNotEmpty ?? false) ? value! : placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: _C.text, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(display, style: const TextStyle(color: _C.text)),
      ],
    );
  }
}

/* ───────────── Pending Activity (accordion) ───────────── */

class _PendingActivityCard extends GetView<ClosureController> {
  const _PendingActivityCard();

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final open = controller.pendingOpen.value;
      final items = controller.pendingActivities;
      final count = items.length;

      return _SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccordionHeader(
              title: 'Pending Activity',
              subtitle: '$count Identified',
              open: open,
              onToggle: controller.pendingOpen.toggle,
            ),

            AnimatedCrossFade(
              crossFadeState: open
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 180),
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    // “Add activity” row
                    const _PendingActivity(
                      text: 'Add activity',
                      icon: CupertinoIcons.list_bullet_below_rectangle,
                    ),
                    const SizedBox(height: 10),

                    // List of returned activities
                    if (count == 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No activities yet. Tap "Add activity" to create one.',
                          style: TextStyle(color: _C.muted, fontSize: 12),
                        ),
                      )
                    else
                      Column(
                        children: items.map((it) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE9EEF5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + status (right)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        it.title,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      it.status,
                                      style: const TextStyle(
                                        color: _C.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // ID + date + assignee
                                Row(
                                  children: [
                                    Text(
                                      it.id,
                                      style: const TextStyle(
                                        color: _C.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (it.targetDate != null) ...[
                                      const Icon(
                                        CupertinoIcons.calendar,
                                        size: 14,
                                        color: _C.muted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _fmtDate(it.targetDate!),
                                        style: const TextStyle(
                                          color: _C.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    const Icon(
                                      CupertinoIcons.person,
                                      size: 14,
                                      color: _C.muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      it.assignee ?? 'Unassigned',
                                      style: const TextStyle(
                                        color: _C.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                if ((it.note ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    it.note!,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}

/* ─────────────────────── SMALL PARTS ─────────────────────── */

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(CupertinoIcons.doc_plaintext, size: 16, color: _C.muted),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(
          color: Color(0xFF3C4354),
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _EnterRowRCA extends GetView<ClosureController> {
  final String text;
  final IconData icon;
  const _EnterRowRCA({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: _C.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      _IconChip(
        icon: icon, //CupertinoIcons.wrench_fill,
        bg: const Color(0xFFEFF4FF),
        fg: _C.primary,
        onTap: () async {
          final res = await Get.toNamed(
            Routes.rcaAnalysisScreen,
            arguments: controller.rcaResult.value,
          );

          if (res is RcaResult) {
            controller.rcaResult.value = res;
          }
        },
      ),
    ],
  );
}

class _PendingActivity extends GetView<ClosureController> {
  final String text;
  final IconData icon;
  const _PendingActivity({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: _C.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      _IconChip(
        icon: icon,

        ///CupertinoIcons.wrench_fill,
        bg: const Color(0xFFEFF4FF),
        fg: _C.primary,
        onTap: () async {
          final res = await Get.toNamed(
            Routes.pendingActivityScreen,
            arguments: PendingActivityArgs(
              initial: List<ActivityItem>.from(controller.pendingActivities),
            ),
          );

          if (res is PendingActivityResult &&
              res.action == PendingActivityAction.back) {
            // use items directly (models, not maps)
            controller.pendingActivities.assignAll(res.activities);
          }
        },
      ),
    ],
  );
}

// class _EnterRowAddActivity extends GetView<ClosureController> {
//   final String text;
//   final IconData icon;
//   const _EnterRowAddActivity({required this.text, required this.icon});
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       Expanded(
//         child: Text(
//           text,
//           style: const TextStyle(
//             color: _C.primary,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//       _IconChip(
//         icon: CupertinoIcons.wrench_fill,
//         bg: const Color(0xFFEFF4FF),
//         fg: _C.primary,
//         onTap: () async {
//           final res = await Get.toNamed(Routes.rcaAnalysisScreen);
//           controller.rcaResult.value = res;
//         },
//       ),
//     ],
//   );
// }

class _KVRow extends StatelessWidget {
  final String leftTitle;
  final String leftValue;
  final String rightTitle;
  final String rightValue;
  const _KVRow({
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(color: _C.muted, fontWeight: FontWeight.w700);
    const valueStyle = TextStyle(color: _C.text, fontWeight: FontWeight.w800);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftTitle, style: titleStyle),
              const SizedBox(height: 4),
              Text(leftValue, style: valueStyle),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(rightTitle, style: titleStyle),
            const SizedBox(height: 4),
            Text(rightValue, style: valueStyle),
          ],
        ),
      ],
    );
  }
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
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
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
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE9EEF5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
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
      style: const TextStyle(
        color: Color(0xFF2F6BFF),
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _AccordionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool open;
  final VoidCallback onToggle;

  const _AccordionHeader({
    required this.title,
    this.subtitle,
    required this.open,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final chevron = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(const AlwaysStoppedAnimation(0));
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _C.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      color: _C.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 180),
          tween: Tween(begin: open ? 1.0 : 0.0, end: open ? 1.0 : 0.0),
          builder: (_, __, child) => Icon(
            open ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
            size: 18,
            color: _C.muted,
          ),
        ),
        IconButton(
          onPressed: onToggle,
          icon: const SizedBox.shrink(),
          splashRadius: 1, // icon above handles the visual
        ),
      ],
    );
  }
}

/* ───────────── Signature Box (shows bytes from SignOff) ───────────── */

class _SignatureBox extends StatelessWidget {
  final Uint8List? bytes;
  const _SignatureBox({this.bytes});

  @override
  Widget build(BuildContext context) {
    final border = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE2E8F0)),
      borderRadius: BorderRadius.circular(10),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 120,
      decoration: border,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: bytes == null
              ? const Text('Signature', style: TextStyle(color: _C.muted))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    clipBehavior: Clip.hardEdge,
                    child: Image.memory(bytes!, gaplessPlayback: true),
                  ),
                ),
        ),
      ),
    );
  }
}

/* ─────────────────────── THEME CONSTS ─────────────────────── */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}

InputDecoration _borderInputDecoration() => InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _C.primary, width: 1.2),
  ),
);
