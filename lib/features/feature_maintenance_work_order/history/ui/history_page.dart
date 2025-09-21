// lib/ui/modules/work_order_management/update_work_order/history/ui/history_page.dart
import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/history/controller/history_controller.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/history/models/history_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double hPad = isTablet ? 20 : 14;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Obx(() {
        final items = controller.items;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No history yet',
                style: TextStyle(
                  color: const Color(0xFF7C8698),
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
          itemCount: items.length + 2,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) return const _Header();
            if (index == 1) return const _StatsCard();
            final item = items[index - 2];
            return _HistoryCard(item: item, isTablet: isTablet);
          },
        );
      }),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => controller.goBack(0),
              child: const Text(
                'Go Back',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================== PRESENTATION PARTS ============================== */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Assets History',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF2D2F39),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    const blue = AppColors.primary;
    const label = TextStyle(
      color: Color(0xFF7C8698),
      fontWeight: FontWeight.w400,
    );
    const value = TextStyle(color: blue, fontWeight: FontWeight.w800);

    Widget cell(String l, String v) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l, style: label.copyWith(fontSize: (label.fontSize ?? 14) - 1)),
        const SizedBox(height: 2),
        Text(v, style: value.copyWith(fontSize: (value.fontSize ?? 14) - 1)),
      ],
    );

    Widget pipe() => const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '|',
        style: TextStyle(color: Color(0xFFE1E7F2), fontWeight: FontWeight.w800),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EEF6)),
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Row(
            children: [
              Expanded(child: cell('MTBF', '110 Days')),
              pipe(),
              Expanded(child: cell('BD Hours', '17 Hrs')),
              pipe(),
              Expanded(child: cell('MTTR', '2.4 Hrs')),
              pipe(),
              Expanded(child: cell('Criticality', 'Semi')),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE6EBF3)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final bool isTablet;
  const _HistoryCard({required this.item, this.isTablet = false});

  Color _chipBg(BuildContext _) => const Color(0xFFEFFFFF);
  Color _chipText(BuildContext _) => const Color(0xFF2D2F39);

  @override
  Widget build(BuildContext context) {
    const textPrimary = Color(0xFF2D2F39);
    const textMuted = Color(0xFF7C8698);

    TextStyle muted([FontWeight w = FontWeight.w600]) => TextStyle(
      color: textMuted,
      fontWeight: w,
      fontSize: isTablet ? 13.5 : 12.5,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // optional: navigate
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE9EEF6)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date + chips row
              Row(
                children: [
                  Text(item.date, style: muted(FontWeight.w700)),
                  const Spacer(),
                  _Chip(
                    text: item.category,
                    bg: _chipBg(context),
                    fg: _chipText(context),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    text: item.type,
                    bg: _chipBg(context),
                    fg: _chipText(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                item.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: isTablet ? 16 : 15,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),

              // Footer: person + duration
              Row(
                children: [
                  const Icon(CupertinoIcons.person, size: 16, color: textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.person,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted(FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(CupertinoIcons.time, size: 16, color: textMuted),
                  const SizedBox(width: 6),
                  Text(item.duration, style: muted(FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Chip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
