import 'package:easy_ops/features/feature_assets_management/assets_details/controller/assets_details_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/* ───────────────────────── Palette ───────────────────────── */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const text = Color(0xFF2D2F39);
  static const muted = Color(0xFF7C8698);
  static const line = Color(0xFFE6EBF3);
  static const card = Colors.white;
  static const chipRed = Color(0xFFEF4444);
  static const chipAmber = Color(0xFFF59E0B);
  static const chipGreen = Color(0xFF10B981);
}

/* ───────────────────────── Page ───────────────────────── */

class AssetsDetailPage extends GetView<AssetsDetailController> {
  const AssetsDetailPage({super.key});

  @override
  AssetsDetailController get controller => Get.put(AssetsDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        title: Obx(() => Text(controller.pageTitle.value)),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? _C.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
        children: const [
          _CardDashboard(),
          SizedBox(height: 12),
          _CardSpecification(),
          SizedBox(height: 12),
          _CardContact(),
          SizedBox(height: 12),
          _CardPmSchedule(),
          SizedBox(height: 12),
          _CardHistory(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

/* ───────────────────────── Reusable wrappers ───────────────────────── */

class _SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  final Widget child;
  const _SectionCard({required this.title, required this.child, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
                const Spacer(),
                if (onMore != null)
                  GestureDetector(
                    onTap: onMore,
                    child: const Text(
                      'View More',
                      style: TextStyle(
                        color: _C.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: _C.line),
          child,
        ],
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  final String label;
  final String value;
  const _KpiCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: _C.muted, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: _C.primary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

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

/* ───────────────────────── Cards ───────────────────────── */

class _CardDashboard extends GetView<AssetsDetailController> {
  const _CardDashboard();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Assets Dashboard',
      onMore: () => controller.onViewMore('Assets Dashboard'),
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const SizedBox(width: 2),
              Expanded(
                child: _KpiCell(label: 'MTBF', value: controller.mtbf.value),
              ),
              _vSep(),
              Expanded(
                child: _KpiCell(
                  label: 'BD Hours',
                  value: controller.bdHours.value,
                ),
              ),
              _vSep(),
              Expanded(
                child: _KpiCell(label: 'MTTR', value: controller.mttr.value),
              ),
              _vSep(),
              Expanded(
                child: _KpiCell(
                  label: 'Criticality',
                  value: controller.criticality.value,
                ),
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vSep() => const SizedBox(
    height: 42,
    child: VerticalDivider(width: 1, color: _C.line, thickness: 1),
  );
}

class _CardSpecification extends GetView<AssetsDetailController> {
  const _CardSpecification();

  Color _pillColor(String p) {
    switch (p.toLowerCase()) {
      case 'critical':
        return _C.chipRed;
      case 'medium':
        return _C.chipAmber;
      default:
        return _C.chipGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Assets Specification',
      onMore: () => controller.onViewMore('Assets Specification'),
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: _C.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(text: controller.assetName.value),
                            const TextSpan(text: '  |  '),
                            TextSpan(
                              text: controller.brand.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _Pill(
                      controller.priority.value,
                      _pillColor(controller.priority.value),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.description.value,
                  style: const TextStyle(color: _C.text, height: 1.3),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    controller.runningState.value,
                    style: const TextStyle(
                      color: _C.muted,
                      fontWeight: FontWeight.w700,
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

class _CardContact extends GetView<AssetsDetailController> {
  const _CardContact();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Manufacturer Contact Info',
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              _contactRow(
                leading: Text(
                  controller.phone.value,
                  style: const TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: IconButton(
                  onPressed: controller.callPhone,
                  icon: const Icon(
                    CupertinoIcons.phone,
                    size: 18,
                    color: _C.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _contactRow(
                leading: Text(
                  controller.email.value,
                  style: const TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: IconButton(
                  onPressed: controller.emailSupport,
                  icon: const Icon(
                    CupertinoIcons.envelope,
                    size: 18,
                    color: _C.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _contactRow(
                leading: Text(
                  controller.address.value,
                  style: const TextStyle(color: _C.text, height: 1.3),
                ),
                trailing: IconButton(
                  onPressed: controller.openMap,
                  icon: const Icon(
                    CupertinoIcons.placemark,
                    size: 18,
                    color: _C.primary,
                  ),
                ),
                alignTop: true,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: _C.line),
              const SizedBox(height: 10),
              ...controller.hours.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.$1,
                          style: const TextStyle(
                            color: _C.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        e.$2,
                        style: const TextStyle(
                          color: _C.text,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactRow({
    required Widget leading,
    required Widget trailing,
    bool alignTop = false,
  }) {
    return Row(
      crossAxisAlignment: alignTop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Expanded(child: leading),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}

class _CardPmSchedule extends GetView<AssetsDetailController> {
  const _CardPmSchedule();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'PM Schedule',
      onMore: () => controller.onViewMore('PM Schedule'),
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.pmType.value,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      controller.pmStatusRightTitle.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.pmTitle.value,
                          style: const TextStyle(
                            color: _C.text,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.pmWhen.value,
                          style: const TextStyle(color: _C.text),
                        ),
                      ],
                    ),
                  ),

                  // Right actions
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: controller.viewActivities,
                          child: const Text(
                            'View Activities',
                            style: TextStyle(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: controller.proposeNew,
                          child: const Text(
                            'Propose New',
                            style: TextStyle(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: controller.viewChecklist,
                          child: const Text(
                            'View Check List',
                            style: TextStyle(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHistory extends GetView<AssetsDetailController> {
  const _CardHistory();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Assets History',
      onMore: () => controller.onViewMore('Assets History'),
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top meta row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.histDate.value,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      controller.histType.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      controller.histDept.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                controller.histText.value,
                style: const TextStyle(color: _C.text, height: 1.3),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.person_crop_circle,
                    size: 16,
                    color: _C.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.histUser.value,
                    style: const TextStyle(
                      color: _C.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(CupertinoIcons.time, size: 16, color: _C.muted),
                  const SizedBox(width: 6),
                  Text(
                    controller.histDuration.value,
                    style: const TextStyle(
                      color: _C.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
