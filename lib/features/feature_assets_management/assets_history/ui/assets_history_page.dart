import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/assets_history_controller.dart';

class AssetsHistoryPage extends GetView<AssetsHistoryController> {
  const AssetsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const _primary = Color(0xFF2F6BFF);
    const _border = Color(0xFFE9EEF5);
    const _bg = Color(0xFFF7F9FC);
    const _text = Color(0xFF2D2F39);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        title: const Text('Assets History'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final a = controller.asset.value;
        final items = controller.visibleHistory;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Header card (outlined)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primary.withOpacity(.35), width: 1),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: _text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(text: a.code),
                              const TextSpan(
                                text: '  |  ',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: a.make,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.description,
                          style: const TextStyle(color: _text, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Working',
                          style: TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _CriticalPill(text: 'Critical'),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Divider(color: _border),

            // Metrics row
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(
                children: [
                  for (int i = 0; i < controller.metrics.length; i++) ...[
                    Expanded(child: _MetricTile(item: controller.metrics[i])),
                    if (i != controller.metrics.length - 1)
                      Container(width: 1, height: 32, color: _border),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: _border),

            const SizedBox(height: 6),
            _Tabs(index: controller.tabIndex.value, onTap: controller.setTab),
            const SizedBox(height: 8),

            // History list
            ...items.map((h) => _HistoryCard(item: h)).toList(),
          ],
        );
      }),
    );
  }
}

// ===== widgets =====

class _CriticalPill extends StatelessWidget {
  final String text;
  const _CriticalPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D4F),
        borderRadius: BorderRadius.circular(20),
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

class _MetricTile extends StatelessWidget {
  final MetricItem item;
  const _MetricTile({required this.item});
  @override
  Widget build(BuildContext context) {
    const _muted = Color(0xFF7C8698);
    const _primary = Color(0xFF2F6BFF);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.value,
          style: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.w800,
            decorationThickness: 2,
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  final int index; // 0,1,2
  final ValueChanged<int> onTap;
  const _Tabs({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const _primary = Color(0xFF2F6BFF);
    const labels = ['All', 'Breakdown', 'Preventive'];

    return Row(
      children: List.generate(labels.length, (i) {
        final selected = i == index;
        return Expanded(
          child: InkWell(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primary,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 3,
                    width: 34,
                    decoration: BoxDecoration(
                      color: selected ? _primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AssetHistoryItem item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    const _muted = Color(0xFF7C8698);
    const _text = Color(0xFF2D2F39);
    final _typeStr = item.type == HistoryType.breakdown
        ? 'Breakdown'
        : 'Preventive';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: date | type | category
          Row(
            children: [
              Text(
                item.date,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                _typeStr,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                item.category,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(
              color: _text,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: _muted),
              const SizedBox(width: 6),
              Text(
                item.assignee,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 16, color: _muted),
              const SizedBox(width: 6),
              Text(
                item.duration,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
