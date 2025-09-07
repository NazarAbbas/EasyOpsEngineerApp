import 'package:easy_ops/constants/values/app_images.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/alerts/controller/alerts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertsPage extends GetView<AlertsController> {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F6BFF),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            controller.hasAlerts
                ? 'Alerts (${controller.totalCount})'
                : 'Alerts',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: controller.hasAlerts ? _AlertsList() : const _EmptyAlertsView(),
      ),
    );
  }
}

/// =============== Empty View (centered) ===============
class _EmptyAlertsView extends StatelessWidget {
  const _EmptyAlertsView();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // responsive image size, avoids overflow on small screens
        final imgSize = (constraints.maxWidth * 0.6).clamp(160.0, 260.0);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              // let Center do vertical centering
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.noAlert,
                  width: imgSize,
                  height: imgSize,
                  fit: BoxFit.contain,
                ),
                const Text(
                  'No Alerts for now!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2F39),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    // Nice simple built-in illustration using icon + shapes (no external assets)
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(height: 4, width: 260, color: const Color(0xFFE9EEF5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 86,
                color: Colors.blue.shade400,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.campaign_rounded,
                size: 120,
                color: Colors.blue.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =============== Alerts List ===============
class _AlertsList extends GetView<AlertsController> {
  @override
  Widget build(BuildContext context) {
    final newAlerts = controller.newAlerts;
    final weekAlerts = controller.weekAlerts;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        if (newAlerts.isNotEmpty) ...[
          _SectionHeader(title: 'New (${controller.newCount})'),
          const SizedBox(height: 8),
          ...newAlerts.map(
            (a) => Obx(
              () => _AlertTile(
                item: a,
                expanded: controller.isExpanded(a.id),
                onToggle: () => controller.toggle(a.id),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (weekAlerts.isNotEmpty) ...[
          const _SectionHeader(title: 'This Week'),
          const SizedBox(height: 8),
          ...weekAlerts.map(
            (a) => Obx(
              () => _AlertTile(
                item: a,
                expanded: controller.isExpanded(a.id),
                onToggle: () => controller.toggle(a.id),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

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

class _AlertTile extends StatelessWidget {
  final AlertItem item;
  final bool expanded;
  final VoidCallback onToggle;

  const _AlertTile({
    required this.item,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final time = _fmtTime(item.timestamp);
    final date = _fmtDate(item.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // time/date + expand icon
                Row(
                  children: [
                    Text(
                      time + (date.isEmpty ? '' : '  |  $date'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A8494),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: expanded ? 0.5 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF7C8698),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // message (one line collapsed)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  firstChild: Text(
                    item.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2D2F39),
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  secondChild: Text(
                    item.message,
                    style: const TextStyle(
                      color: Color(0xFF2D2F39),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============== Utils ===============
String _fmtTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  final mm = dt.minute.toString().padLeft(2, '0');
  return '${h.toString().padLeft(2, '0')}:$mm $ampm';
}

String _fmtDate(DateTime dt) {
  final now = DateTime.now();
  // if today we don't show date under "New" section header; still keep for week
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day)
    return '';
  const m = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];
  return '${dt.day.toString().padLeft(2, '0')}/${m[dt.month - 1]}/${dt.year}';
}
