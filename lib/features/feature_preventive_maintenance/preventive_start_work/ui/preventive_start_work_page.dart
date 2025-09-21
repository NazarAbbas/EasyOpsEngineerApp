import 'package:easy_ops/features/feature_preventive_maintenance/preventive_start_work/controller/preventive_start_work_controller.dart';
import 'package:easy_ops/features/feature_preventive_maintenance/preventive_start_work/models/preventive_start_work.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const text = Color(0xFF1F2430);
  static const muted = Color(0xFF7C8698);
  static const border = Color(0xFFE9EEF5);
  static const danger = Color(0xFFED3B40);
}

class PreventiveStartWorkPage extends GetView<PreventiveStartWorkController> {
  const PreventiveStartWorkPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    Get.put(PreventiveStartWorkController(), permanent: false);

    final isTablet = _isTablet(context);
    final hPad = isTablet ? 20.0 : 14.0;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Work Order',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 120),
        children: const [
          _MachineCard(),
          SizedBox(height: 12),
          _MetricsGrid(),
          SizedBox(height: 12),
          _PreventiveScheduleCard(),
          SizedBox(height: 12),
          _ScheduleAcceptedCard(),
          SizedBox(height: 12),
          _ResourcesCard(),
          SizedBox(height: 12),
          _PendingActivityCard(),
        ],
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
                    side: BorderSide(color: primary),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed:
                      Get.find<PreventiveStartWorkController>().otherOptions,
                  child: const Text(
                    'Other Options',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed:
                      Get.find<PreventiveStartWorkController>().startWork,
                  child: const Text(
                    'Start Work',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800),
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

class _MachineCard extends GetView<PreventiveStartWorkController> {
  const _MachineCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    '${controller.machineName.value}  |  ${controller.brand.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _Pill(text: 'Critical', color: _C.danger),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  size: 18,
                  color: _C.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.location.value,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _C.text),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            controller.runningStatusText.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
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
        ],
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
    final bg = color == _C.danger
        ? const Color(0xFFFFEAEA)
        : const Color(0xFFEFF4FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

/* ───────────────────────── Metrics ───────────────────────── */

class _MetricsGrid extends GetView<PreventiveStartWorkController> {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final cols = w >= 600 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.8,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _metric('MTBF', controller.mtbf),
              _metric('BD Hours', controller.bdHours),
              _metric('MTTR', controller.mttr),
              _metric('Criticality', controller.criticality),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(String title, RxString value) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _C.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _C.muted, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value.value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _C.primary,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────── Preventive + Schedule ──────────────────── */

class _PreventiveScheduleCard extends GetView<PreventiveStartWorkController> {
  const _PreventiveScheduleCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(
                  child: Text(
                    'Preventive',
                    style: TextStyle(
                      fontSize: 13,
                      color: _C.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 13,
                    color: _C.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.preventiveTitle.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.scheduledLine1.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _C.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        controller.scheduledLine2.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _C.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.pendingHours.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: controller.proposeNew,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'Propose New',
                          style: TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────── Schedule Accepted By ───────────────────── */

class _ScheduleAcceptedCard extends GetView<PreventiveStartWorkController> {
  const _ScheduleAcceptedCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.scheduleAcceptedExpanded.value;
      return _SoftCard(
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Schedule Accepted By',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3C4658),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.scheduleAcceptedExpanded.toggle(),
                  icon: Icon(
                    expanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                  ),
                ),
              ],
            ),
            if (expanded) const SizedBox(height: 6),
            if (expanded)
              ...controller.acceptedBy.map((p) => _personRow(p)).toList(),
          ],
        ),
      );
    });
  }

  Widget _personRow(AcceptedBy p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              p.dept,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _C.muted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () =>
                Get.find<PreventiveStartWorkController>().call(p.phone),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F1FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.phone,
                color: _C.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────── Resources Required ───────────────────── */

class _ResourcesCard extends GetView<PreventiveStartWorkController> {
  const _ResourcesCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.resourcesExpanded.value;
      return _SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Resources Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3C4658),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.resourcesExpanded.toggle(),
                  icon: Icon(
                    expanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                '${controller.identifiedResources} Identified',
                style: const TextStyle(color: _C.muted),
              ),
            ),
            if (expanded) const SizedBox(height: 12),
            if (expanded)
              ...controller.resources.map((r) => _resourceRow(r)).toList(),
            if (expanded) const SizedBox(height: 10),
            if (expanded)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: controller.addMoreResources,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Add more resources',
                          style: TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ghostButton(
                    icon: CupertinoIcons.list_bullet_indent,
                    onTap: controller.addMoreResources,
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _resourceRow(ResourceItem r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              r.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _C.text),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${r.qty}',
            style: const TextStyle(fontWeight: FontWeight.w700, color: _C.text),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────── Pending Activity ───────────────────── */

class _PendingActivityCard extends GetView<PreventiveStartWorkController> {
  const _PendingActivityCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.activitiesExpanded.value;
      return _SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Pending Activity',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3C4658),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.activitiesExpanded.toggle(),
                  icon: Icon(
                    expanded
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                '${controller.identifiedActivities} Identified',
                style: const TextStyle(color: _C.muted),
              ),
            ),
            if (expanded) const SizedBox(height: 10),
            if (expanded)
              ...controller.activities.asMap().entries.map((e) {
                final i = e.key;
                final a = e.value;
                return Column(
                  children: [
                    _activityTile(a),
                    if (i != controller.activities.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: _C.border),
                      ),
                  ],
                );
              }),
            if (expanded) const SizedBox(height: 10),
            if (expanded)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: controller.addMoreActivity,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Add more activity',
                          style: TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ghostButton(
                    icon: CupertinoIcons.list_bullet_indent,
                    onTap: controller.addMoreActivity,
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _activityTile(ActivityItem a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                '${a.code}   ${a.time} | ${a.date}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _C.muted),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              a.status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _C.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(a.type, style: const TextStyle(color: _C.text)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    a.bdCode,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.find<PreventiveStartWorkController>()
                        .viewDetails(a),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _C.primary),
                foregroundColor: _C.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () =>
                  Get.find<PreventiveStartWorkController>().closeActivity(a),
              child: const Text('Close', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ],
    );
  }
}

/* ───────────────────────── Helpers ───────────────────────── */

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: child,
    );
  }
}

Widget _ghostButton({required IconData icon, required VoidCallback onTap}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE9F1FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _C.primary, size: 18),
      ),
    ),
  );
}
