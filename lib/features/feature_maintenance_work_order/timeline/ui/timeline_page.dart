// timeline_page.dart (fixed)
import 'package:easy_ops/features/feature_maintenance_work_order/timeline/controller/timeline_controller.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/timeline/models/timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TimelinePage extends GetView<TimelineController> {
  const TimelinePage({super.key});

  // @override
  // WorkOrderTimelineController get controller =>
  //     Get.put<WorkOrderTimelineController>(WorkOrderTimelineController());

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final hPad = isTablet ? 18.0 : 14.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      // ❌ no outer Obx here
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
        child: Column(
          children: [
            _IssueHeaderCard(controller: controller), // has its own Obx inside
            const SizedBox(height: 8),
            const Divider(height: 1, color: _C.line),
            _TimelineList(controller: controller), // Obx inside
            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 10),
          child: SizedBox(
            height: isTablet ? 56 : 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => {controller.goBack(0)},
              child: const Text(
                'Go Back',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- ISSUE HEADER ---------------- */

class _IssueHeaderCard extends StatelessWidget {
  final TimelineController controller;
  const _IssueHeaderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
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
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${controller.woId.value}   ${controller.time.value} | ${controller.date.value}',
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
                      children: [
                        const Icon(
                          CupertinoIcons.time,
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

class _RichLines extends StatelessWidget {
  final List<RichLine> lines;
  const _RichLines({required this.lines});

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    for (final l in lines) {
      if (l.isLink) {
        spans.add(
          TextSpan(
            text: l.text,
            style: const TextStyle(
              color: _C.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = l.onTap,
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: l.text,
            style: const TextStyle(
              color: _C.text,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        );
      }
    }
    return Text.rich(TextSpan(children: spans));
  }
}

/* ---------------- STYLES ---------------- */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
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

/* ---------------- TIMELINE CONSTANTS ---------------- */
const double _tilePadL = 8; // left padding inside each tile
const double _gutterW = 20; // left gutter width for the timeline
const double _lineW = 2; // vertical line thickness
const double _dotSize = 8; // circle size
const double _lineLeft = _tilePadL + (_gutterW / 2) - (_lineW / 2);

/* ---------------- TIMELINE LIST (continuous line) ---------------- */

class _TimelineList extends StatelessWidget {
  final TimelineController controller;
  const _TimelineList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.items;

      return Stack(
        children: [
          // 1) ONE continuous background line for the whole list
          Positioned.fill(
            left: _lineLeft,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(width: _lineW, color: const Color(0xFFE5EAF2)),
            ),
          ),

          // 2) The list itself (no separators that break the line)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (_, i) => _TimelineTile(event: items[i]),
          ),
        ],
      );
    });
  }
}

/* ---------------- SINGLE TILE (draw only the dot) ---------------- */

class _TimelineTile extends StatelessWidget {
  final TimelineEvent event;
  const _TimelineTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_tilePadL, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left gutter: only the dot; the line is drawn behind by the Stack
          SizedBox(
            width: _gutterW,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _dotSize,
                height: _dotSize,
                decoration: const BoxDecoration(
                  color: _C.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.time} | ${event.date}',
                  style: const TextStyle(
                    color: _C.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                _RichLines(lines: event.lines),

                if (event.showDetails) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: event.onViewDetails,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: _C.primary,
                        ),
                      ],
                    ),
                  ),
                ],

                // optional light divider under content (doesn't cross the gutter)
                const SizedBox(height: 12),
                const Divider(height: 1, color: _C.line),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
