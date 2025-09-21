import 'package:easy_ops/features/feature_spare_parts/consume_spare_parts/controller/consume_spare_parts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConsumedSparePartsPage extends GetView<ConsumedSparePartsController> {
  const ConsumedSparePartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: controller.tabIndex.value == 1
            ? const _ConsumedTab()
            : const _ReturnsPlaceholder(),
      ),
    );
  }
}

/// ---------------- Consumed Tab ----------------
class _ConsumedTab extends GetView<ConsumedSparePartsController> {
  const _ConsumedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Obx(() {
      final list = controller.consumedTickets;
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemBuilder: (_, i) {
          final t = list[i];
          final meta =
              '${t.bdNo} | ${_fmtTime(t.createdAt)} | ${_fmtDate(t.createdAt)} | ${t.machine}';
          final subtitle = '${t.totalQty} spares consumed';

          // ⬇️ Each tile listens to expanded map
          return Obx(() {
            final expanded = controller.isExpandedConsumed(t.id);

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => controller.toggleExpandedConsumed(t.id),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Collapsed header row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meta,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2D2F39),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A8494),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: expanded ? 0.5 : 0.0,
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF2F6BFF),
                              ),
                            ),
                          ],
                        ),

                        // Expanded content
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              children: [
                                // Title + right column
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.issueTitle,
                                            style: const TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF2D2F39),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                t.department,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF2D2F39),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(
                                                Icons.warning_amber_rounded,
                                                size: 16,
                                                color: Color(0xFFE55A52),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                t.machine,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  color: Color(0xFF7A8494),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _Pill(
                                          text: 'High',
                                          color: _priorityColor(t.priority),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 14,
                                              color: Color(0xFF7A8494),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              t.agingText,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF7A8494),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t.resolved ? 'Resolved' : 'Open',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: t.resolved
                                                ? const Color(0xFF3AB97A)
                                                : const Color(0xFFE7A23C),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                const _CenterDivider(title: 'Spares Consumed'),
                                const SizedBox(height: 10),

                                // Header row
                                Row(
                                  children: const [
                                    Expanded(
                                      child: Text(
                                        'Part Name',
                                        style: TextStyle(
                                          color: Color(0xFF7A8494),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    SizedBox(
                                      width: 56,
                                      child: Text(
                                        'Qty.',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Color(0xFF7A8494),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        'Is Repairable?',
                                        style: TextStyle(
                                          color: Color(0xFF7A8494),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Lines
                                ...List.generate(t.lines.length, (idx) {
                                  final line = t.lines[idx];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: idx == t.lines.length - 1
                                          ? 0
                                          : 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            line.partNo,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2D2F39),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 56,
                                          child: Text(
                                            '${line.qty} nos',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              color: Color(0xFF2D2F39),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Obx(
                                          () => _RepairToggle(
                                            value: line.choice.value,
                                            onChanged: (v) => controller
                                                .setChoice(t.id, idx, v),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                const SizedBox(height: 16),
                                SizedBox(
                                  width: 160,
                                  height: 42,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () =>
                                        controller.submitConsumed(t.id),
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
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
                ),
              ),
            );
          });
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: list.length,
      );
    });
  }
}

class _ReturnsPlaceholder extends StatelessWidget {
  const _ReturnsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Returns tab (placeholder)',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// --------- Small widgets ---------
class _RepairToggle extends StatelessWidget {
  final RepairChoice value;
  final ValueChanged<RepairChoice> onChanged;
  const _RepairToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color sel(bool active) =>
        active ? const Color(0xFF2F6BFF) : const Color(0xFFE9EEF5);
    Color icon(bool active) => active ? Colors.white : const Color(0xFF7A8494);

    return Container(
      width: 120,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          _smallPill(
            bg: sel(value == RepairChoice.scrap),
            icon: Icons.delete_outline,
            iconColor: icon(value == RepairChoice.scrap),
            onTap: () => onChanged(RepairChoice.scrap),
          ),
          const Spacer(),
          _smallPill(
            bg: sel(value == RepairChoice.repair),
            icon: Icons.build_rounded,
            iconColor: icon(value == RepairChoice.repair),
            onTap: () => onChanged(RepairChoice.repair),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _smallPill({
    required Color bg,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 28,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 16, color: iconColor),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const ShapeDecoration(
        color: Color(0xFFE55A52),
        shape: StadiumBorder(),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _priorityColor(Priority p) => switch (p) {
  Priority.high => const Color(0xFFE55A52),
  Priority.medium => const Color(0xFFE7A23C),
  Priority.low => const Color(0xFF3AB97A),
};

class _CenterDivider extends StatelessWidget {
  final String title;
  const _CenterDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE1E6EF), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7A8494),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE1E6EF), thickness: 1)),
      ],
    );
  }
}

/// --------- Utils ---------
String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _fmtDate(DateTime dt) {
  const m = [
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
  return '${dt.day.toString().padLeft(2, '0')} ${m[dt.month - 1]}';
}
