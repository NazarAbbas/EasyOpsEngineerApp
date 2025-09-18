import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/home_dashboard/controller/home_dashboard_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/ui/work_order_management_list_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeDashboardPage extends GetView<HomeDashboardController> {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // ======= HEADER =======
          _Header(
            height: 150,
            onBellTap: () {
              Get.toNamed(Routes.alertScreen);
            },
            onMenuSelect: (value) {
              switch (value) {
                case 'profile':
                  Get.toNamed(Routes.profileScreen);
                  break;
                case 'support':
                  Get.toNamed(Routes.supportScreen);
                  break;
                case 'suggestions':
                  Get.toNamed(Routes.suggestionScreen);
                  break;
                case 'signout':
                  c.signOut();
                  break;
              }
            },
          ),

          // ======= CONTENT =======
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    // Work Orders row (includes All & Breakdown)
                    Obx(
                      () => _SectionCard(
                        title: c.summary.value.title, // "Work Orders"
                        stats: c.summary.value,
                        onTap: (item) => c.onTileTap(c.summary.value, item),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Breakdown
                    Obx(
                      () => _SectionCard(
                        title: c.breakdown.value.title,
                        stats: c.breakdown.value,
                        onTap: (item) => c.onTileTap(c.breakdown.value, item),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Preventive
                    Obx(
                      () => _SectionCard(
                        title: c.preventive.value.title,
                        stats: c.preventive.value,
                        onTap: (item) => c.onTileTap(c.preventive.value, item),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Assets
                    Obx(
                      () => _SectionCard(
                        title: c.assets.value.title,
                        stats: c.assets.value,
                        onTap: (item) => c.onTileTap(c.assets.value, item),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ==== NEW: Dashboard (chart image) ====
                    _DashboardCard(
                      title: 'Dashboard',
                      image: _BreakdownBarChart(
                        months: c.months,
                        values: c.breakdownHrs,
                        avgLine: c.breakdownAvg,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ==== NEW: My Team section ====
                    Obx(
                      () => _SectionCard(
                        title: c.myTeam.value.title, // "My Team"
                        stats: c.myTeam.value,
                        onTap: (item) => c.onTileTap(c.myTeam.value, item),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      //bottomNavigationBar: const BottomBar(currentIndex: 0),
    );
  }
}

// ==================== HEADER ====================

// ==================== HEADER (drop-in replacement) ====================
class _Header extends StatelessWidget {
  final double height;
  final VoidCallback onBellTap;
  final void Function(String value) onMenuSelect;

  const _Header({
    required this.height,
    required this.onBellTap,
    required this.onMenuSelect,
  });

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    final top = MediaQuery.of(context).padding.top;
    final isTablet = _isTablet(context);

    // Compact, consistent sizing
    const double hPad = 16;
    const double vPadTop = 8;
    const double vPadBottom = 12;
    final double btnSize = isTablet ? 40 : 36;
    const double gap = 10;

    // final canPop = Navigator.of(context).canPop();

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(
        hPad,
        vPadTop,
        hPad,
        vPadBottom,
      ).copyWith(top: top + vPadTop),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 8),
            color: Color(0x33000000),
          ),
        ],
      ),
      // Stack prevents horizontal overflow while keeping the title centered.
      child: Stack(
        alignment: Alignment.center,
        children: [
          // LEFT: (optional back) + profile menu
          Align(
            alignment: Alignment.centerLeft,

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_ProfileMenu(onSelected: onMenuSelect)],
            ),
          ),

          // CENTER: Title (ellipsized)
          const Center(
            child: Text(
              'Maintenance Engineer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // RIGHT: Notification bell
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: btnSize,
              height: btnSize,
              child: IconButton(
                onPressed: onBellTap,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  width: btnSize,
                  height: btnSize,
                ),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
                tooltip: 'Notifications',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable circular icon button with ripple
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final void Function(String value) onSelected;
  const _ProfileMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 44),
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => [
        _menuItem('profile', Icons.person_outline, 'My Profile'),
        _menuItem('support', Icons.headset_mic_outlined, 'Support'),
        _menuItem('suggestions', Icons.chat_bubble_outline, 'Suggestions'),
        const PopupMenuDivider(),
        _menuItem('signout', Icons.logout, 'Sign Out', danger: true),
      ],
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFEAF2FF),
        child: const Icon(Icons.person, color: Color(0xFF2F6BFF), size: 20),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String v,
    IconData i,
    String t, {
    bool danger = false,
  }) {
    return PopupMenuItem<String>(
      value: v,
      child: Row(
        children: [
          Icon(i, size: 18, color: danger ? const Color(0xFFDB3A34) : null),
          const SizedBox(width: 10),
          Text(
            t,
            style: TextStyle(
              color: danger ? const Color(0xFFDB3A34) : null,
              fontWeight: danger ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SECTION + TILES ====================
class _SectionCard extends GetView<HomeDashboardController> {
  final String? title;
  final SectionStats stats;
  final void Function(StatItem item) onTap;

  const _SectionCard({
    required this.title,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: -2,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        children: [
          if (title != null && title!.isNotEmpty)
            _SectionHeader(
              title: title!,
              onTap: () {
                controller.onSummeryHeaderTap(title!);
                // your navigation or action here
              },
            ),
          // _SectionHeader(title: title!),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const gap = 10.0; // breathing room between tiles
                final w = (constraints.maxWidth - (gap * 3)) / 4; // 4 per row
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: stats.items.map((item) {
                    return SizedBox(
                      width: w,
                      child: _StatTile(item: item, onTap: () => onTap(item)),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap; // <-- pass from caller
  final bool showChevron;

  const _SectionHeader({
    required this.title,
    this.onTap,
    this.showChevron = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Material + InkWell for ripple on both iOS/Android
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE9EEF5))),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: Color(0xFF2D2F39),
                ),
              ),
              const Spacer(),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: onTap == null
                      ? const Color(0xFFBFC6D2)
                      : const Color(0xFF7C8698),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final StatItem item;
  final VoidCallback onTap;
  const _StatTile({required this.item, required this.onTap});

  Color _bg(StatTone t) => switch (t) {
    StatTone.critical => const Color(0xFFFFE8E8),
    StatTone.warning => const Color(0xFFFFF3D6),
    StatTone.success => const Color(0xFFE9F9EE),
    StatTone.info => const Color(0xFFEAF2FF),
    _ => const Color(0xFFF2F4F8),
  };

  Color _fg(StatTone t) => switch (t) {
    StatTone.critical => const Color(0xFFDB3A34),
    StatTone.warning => const Color(0xFF946200),
    StatTone.success => const Color(0xFF1D7A3D),
    StatTone.info => const Color(0xFF2F6BFF),
    _ => const Color(0xFF2D2F39),
  };

  @override
  Widget build(BuildContext context) {
    final isAction = item.isAction;
    final bg = _bg(item.tone);
    final fg = _fg(item.tone);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAction)
                const Icon(Icons.add, size: 18, color: Color(0xFF2F6BFF))
              else
                Text(
                  '${item.value}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isAction
                      ? const Color(0xFF2F6BFF)
                      : const Color(0xFF7C8698),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DASHBOARD CHART CARD (NEW) ====================
class _DashboardCard extends GetView<HomeDashboardController> {
  final String title;
  final Widget image; // pass any chart widget or image

  const _DashboardCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: -2,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        children: [
          // _SectionHeader(
          //   title: title!,
          //   onTap: () {
          //     controller.onSummeryHeaderTap(controller.summary.value.title);
          //     // your navigation or action here
          //   },
          // ),
          _SectionHeader(title: title),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(14),
            ),
            child: AspectRatio(aspectRatio: 16 / 9, child: image),
          ),
        ],
      ),
    );
  }
}

class _BreakdownBarChart extends StatelessWidget {
  final List<String> months;
  final List<double> values;
  final double avgLine;

  const _BreakdownBarChart({
    required this.months,
    required this.values,
    required this.avgLine,
  });

  @override
  Widget build(BuildContext context) {
    final maxY =
        (values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b)) * 1.15;

    return Stack(
      children: [
        // leave space on top for the in-chart title
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 28, 16, 12),
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, _, rod, __) {
                    final m = months[group.x.toInt()];
                    final v = rod.toY.toStringAsFixed(0);
                    return BarTooltipItem(
                      '$m\n$v hrs',
                      const TextStyle(color: Color(0xFF2D2F39)),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (y) =>
                    const FlLine(color: Color(0xFFE9EEF5), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: maxY / 5,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7C8698),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36, // make room for all labels
                    interval: 1, // <-- show every month
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= months.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 6,
                        child: Transform.rotate(
                          angle: -0.7, // ~ -40°, fits all months neatly
                          child: Text(
                            months[i],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF7C8698),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(months.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: i < values.length ? values[i] : 0,
                      width: 12, // a bit slimmer so 12 bars + labels fit
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      color: const Color(0xFF2F6BFF),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: const Color(0xFFF3F5F9),
                      ),
                    ),
                  ],
                );
              }),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: avgLine,
                    color: const Color(0xFFDB3A34),
                    strokeWidth: 2,
                    dashArray: [6, 3],
                  ),
                ],
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 300),
          ),
        ),

        // In-chart title like the screenshot
        const Positioned(
          top: 6,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Breakdown  HRS',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2F39),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
