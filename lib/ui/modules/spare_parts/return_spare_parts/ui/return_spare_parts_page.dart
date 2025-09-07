import 'package:easy_ops/ui/modules/spare_parts/return_spare_parts/controller/return_spare_parts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnSparePartsPage extends GetView<ReturnSparePartsController> {
  const ReturnSparePartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: controller.tabIndex.value == 0
            ? const _ReturnsTab()
            : const _ConsumedTab(),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: controller.returnAll,
                child: const Text(
                  'Return All',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- Tabs (Returns / Consumed) ----------------
class _Tabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _Tabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5E6572),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _TabButton(
            text: 'Returns',
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 10),
          _TabButton(
            text: 'Consumed',
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFF555C68),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? const Color(0xFF2D2F39) : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- Returns Tab ----------------
class _ReturnsTab extends GetView<ReturnSparePartsController> {
  const _ReturnsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tickets = controller.returns;
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemBuilder: (ctx, i) {
          final t = tickets[i];
          final meta =
              '${t.bdNo} | ${_fmtTime(t.createdAt)} | ${_fmtDate(t.createdAt)} | ${t.machine}';
          final subtitle = '${t.totalQty} Spares to be Returned';

          return Obx(
            () => _TicketCard(
              meta: meta,
              subtitle: subtitle,
              ticket: t,
              expanded: controller.isExpanded(t.id),
              onToggle: () => controller.toggleExpand(t.id),
              onReturn: () => controller.returnTicket(t.id),
              onEditLine: (idx) => controller.editQty(t.id, idx),
              onDeleteLine: (idx) => controller.deleteLine(t.id, idx),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: tickets.length,
      );
    });
  }
}

class _TicketCard extends StatelessWidget {
  final String meta;
  final String subtitle;
  final SpareTicket ticket;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onReturn;
  final void Function(int index) onEditLine;
  final void Function(int index) onDeleteLine;

  const _TicketCard({
    required this.meta,
    required this.subtitle,
    required this.ticket,
    required this.expanded,
    required this.onToggle,
    required this.onReturn,
    required this.onEditLine,
    required this.onDeleteLine,
  });

  Color _priorityColor(Priority p) => switch (p) {
    Priority.high => const Color(0xFFE55A52),
    Priority.medium => const Color(0xFFE7A23C),
    Priority.low => const Color(0xFF3AB97A),
  };

  @override
  Widget build(BuildContext context) {
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
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top meta + chevron
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

                // Expanded section
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
                        // Issue title + priority + aging/resolved
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.issueTitle,
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
                                        ticket.department,
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
                                        ticket.machine,
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _Pill(
                                  text: 'High',
                                  color: _priorityColor(ticket.priority),
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
                                      ticket.agingText,
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
                                  ticket.resolved ? 'Resolved' : 'In Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ticket.resolved
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

                        _CenterDivider(title: 'Spares to be Returned'),
                        const SizedBox(height: 8),

                        // lines
                        ...List.generate(ticket.lines.length, (i) {
                          final line = ticket.lines[i];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i == ticket.lines.length - 1 ? 0 : 10,
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
                                Text(
                                  '${line.qty} nos',
                                  style: const TextStyle(
                                    color: Color(0xFF2D2F39),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Color(0xFF2F6BFF),
                                  ),
                                  onPressed: () => onEditLine(i),
                                  tooltip: 'Edit quantity',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Color(0xFF2F6BFF),
                                  ),
                                  onPressed: () => onDeleteLine(i),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 14),
                        SizedBox(
                          width: 160,
                          height: 42,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2F6BFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: onReturn,
                            child: const Text(
                              'Return',
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
      decoration: ShapeDecoration(color: color, shape: const StadiumBorder()),
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
              color: Color(0xFF7C8698),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE1E6EF), thickness: 1)),
      ],
    );
  }
}

/// ---------------- Consumed Tab ----------------
class _ConsumedTab extends GetView<ReturnSparePartsController> {
  const _ConsumedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.consumed;
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemBuilder: (_, i) {
          final line = list[i];
          return Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    line.partNo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2F39),
                    ),
                  ),
                ),
                Text(
                  '${line.qty} nos',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2F39),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: list.length,
      );
    });
  }
}

/// ---------------- Utils ----------------
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
