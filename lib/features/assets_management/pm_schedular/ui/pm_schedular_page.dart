import 'package:easy_ops/features/assets_management/pm_schedular/controller/pm_schedular_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PMSchedulePage extends GetView<PMScheduleController> {
  const PMSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    const _primary = Color(0xFF2F6BFF);
    const _border = Color(0xFFE9EEF5);
    const _bg = Color(0xFFF7F9FC);
    const _text = Color(0xFF2D2F39);
    const _muted = Color(0xFF7C8698);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        title: const Text('PM Schedule'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final a = controller.asset.value;
        final up = controller.upcoming.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              // Header card (outlined)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primary.withOpacity(.35),
                    width: 1,
                  ),
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
                          Text(
                            a.status,
                            style: const TextStyle(
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

              const SizedBox(height: 14),

              // Metrics row
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
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

              const SizedBox(height: 16),

              // Upcoming PM section
              _SectionHeader(
                title: 'Upcoming PM',
                border: _border,
                muted: _muted,
              ),
              const SizedBox(height: 8),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top line: type + status + link
                    Row(
                      children: [
                        Text(
                          up.type,
                          style: const TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      up.title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Due by ${up.dueBy}',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.onViewActivities,
                          child: const Text('View Activities'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // PM History section
              _SectionHeader(
                title: 'PM History',
                border: _border,
                muted: _muted,
              ),
              const SizedBox(height: 8),
              ...controller.history
                  .map(
                    (h) => _HistoryTile(
                      item: h,
                      onTap: () => controller.onSeeDetails(h),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      }),
    );
  }
}

// ---- widgets ----

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

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color border;
  final Color muted;
  const _SectionHeader({
    required this.title,
    required this.border,
    required this.muted,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: TextStyle(color: muted, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(child: Divider(color: border)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    const _border = Color(0xFFE9EEF5);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PMHistoryItem item;
  final VoidCallback onTap;
  const _HistoryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const _text = Color(0xFF2D2F39);
    const _muted = Color(0xFF7C8698);
    const _border = Color(0xFFE9EEF5);
    const _primary = Color(0xFF2F6BFF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + type + status (Completed)
          Row(
            children: [
              Text(
                item.date,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.type,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (item.completed)
                Row(
                  children: const [
                    Icon(Icons.check_circle, size: 16, color: _primary),
                    SizedBox(width: 6),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              color: _text,
              fontSize: 15,
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
              TextButton.icon(
                onPressed: onTap,
                icon: const Text('See Details'),
                label: const Icon(Icons.chevron_right_rounded, size: 18),
                style: TextButton.styleFrom(
                  foregroundColor: _primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
