// ignore_for_file: deprecated_member_use

import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/maintenance_work_order/diagnostics/controller/diagnostics_controller.dart'
    hide WorkOrder;
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/controller/work_order_management_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/models/work_order.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class WorkOrdersManagementPage extends GetView<WorkOrdersManagementController> {
  const WorkOrdersManagementPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    final double headerH = isTablet ? 148 : 120;
    final double hPad = isTablet ? 16 : 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: const _GradientHeader(),
      ),
      body: Column(
        children: [
          _Tabs(),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              // 1) First-load spinner driven by controller.loading
              if (controller.loading.value) {
                return const _InitialLoading();
              }

              final List<WorkOrder> data = controller.visibleOrders;
              if (data.isEmpty) {
                return _EmptyState(
                  onCreate: () =>
                      {}, // Get.toNamed(Routes.workOrderTabShellScreen),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshOrders,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _WorkOrderCard(order: data[i]),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 2),
    );
  }
}

/* ───────────────────────── Header ───────────────────────── */

class _GradientHeader extends GetView<WorkOrdersManagementController>
    implements PreferredSizeWidget {
  const _GradientHeader();

  @override
  WorkOrdersManagementController get controller =>
      Get.find<WorkOrdersManagementController>();

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Work Order Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SearchField(
                  onChanged: controller.setQuery, // <- uses controller
                ),
              ),
              const SizedBox(width: 12),
              _IconSquare(
                onTap: () {
                  Get.dialog(
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              color: Colors.white,
                              elevation: 8,
                              clipBehavior: Clip.antiAlias,
                              child: const _CalendarCard(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: true,
                    barrierColor: Colors.black.withOpacity(0.35),
                    useSafeArea: true,
                  );
                },
                bg: Colors.white.withOpacity(0.18),
                outline: const Color(0x66FFFFFF),
                child: const Icon(CupertinoIcons.calendar, color: Colors.white),
              ),
              const SizedBox(width: 12),
              _IconSquare(
                onTap: () {},
                bg: Colors.white.withOpacity(0.18),
                outline: const Color(0x66FFFFFF),
                child: const Icon(CupertinoIcons.plus, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Calendar ───────────────────────── */

class _CalendarCard extends GetView<WorkOrdersManagementController> {
  const _CalendarCard();

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double rowH = isTablet ? 40 : 34;
    final double dowH = isTablet ? 22 : 20;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Obx(() {
        return TableCalendar<MarkerEvent>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: controller.focusedDay.value,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          shouldFillViewport: false,
          sixWeekMonthsEnforced: false,
          rowHeight: rowH,
          daysOfWeekHeight: dowH,
          selectedDayPredicate: (d) =>
              isSameDay(d, controller.selectedDay.value),
          onDaySelected: (sel, foc) {
            controller.selectedDay.value = sel;
            controller.focusedDay.value = foc;
            Get.back();
          },
          onPageChanged: (foc) => controller.focusedDay.value = foc,
          eventLoader: controller.eventsFor,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF345E9E),
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF345E9E)),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Color(0xFF345E9E),
            ),
            headerMargin: EdgeInsets.only(bottom: 6),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Color(0xFF99A3B0),
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: TextStyle(
              color: Color(0xFF99A3B0),
              fontWeight: FontWeight.w600,
            ),
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: TextStyle(color: Color(0xFF2D2F39)),
            weekendTextStyle: TextStyle(color: Color(0xFF2D2F39)),
            todayDecoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xFFE8F0FF),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          calendarBuilders: CalendarBuilders<MarkerEvent>(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(4).map((e) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 4.2,
                        height: 4.2,
                        decoration: BoxDecoration(
                          color: e.color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/* ───────────────────────── List items ───────────────────────── */

class _WorkOrderCard extends StatelessWidget {
  final WorkOrder order;
  const _WorkOrderCard({required this.order});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    // Sizing
    final double radius = isTablet ? 16 : 12;
    final double pad = isTablet ? 16 : 14;
    final double titleSize = isTablet ? 16 : 14;
    final double metaSize = isTablet ? 13.5 : 12.5;
    final double labelSize = isTablet ? 14.5 : 13.5;

    // Colors
    const textPrimary = Color(0xFF111827);
    const textSecondary = Color(0xFF6B7280);
    const borderSoft = Color(0xFFE9EEF5);
    final accent = _accentFor(order);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: borderSoft, width: 1),
      ),
      child: InkWell(
        onTap: () => {
          if (order.status.name == 'resolved')
            {Get.toNamed(Routes.updateWorkOrderTabScreen, arguments: order)}
          else
            {Get.toNamed(Routes.workOrderDetailScreen, arguments: order)},
        },

        child: Stack(
          children: [
            // Accent stripe
            Positioned.fill(
              left: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 3, color: accent),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(pad + 2, pad, pad, pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Title + status + chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // severity dot + title
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // _SeverityDot(color: accent),
                            // const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (order.status != Status.resolved) ...[
                        const SizedBox(width: 15),
                        _StatusPill(pill: order.priority),
                      ],
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Meta row: [code]  [time | date................]                [STATUS -> right]
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // left: code
                      _MetaChip(icon: CupertinoIcons.number, label: order.code),

                      const SizedBox(width: 8),

                      // middle: time | date (expands), keeps left alignment
                      Expanded(
                        child: _MetaChip(
                          icon: null,
                          label: '${order.time} | ${order.date}',
                        ),
                      ),

                      const SizedBox(width: 8),

                      // right: status (only if not 'none')
                      if (order.status != Status.none)
                        Text(
                          order.status.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: order.status.color,
                            fontWeight: FontWeight.w800,
                            fontSize: labelSize,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Divider (soft)
                  const Divider(height: 1, color: borderSoft),

                  const SizedBox(height: 12),

                  // Bottom info: left (dept & line) | right (badge + duration + tag)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Department
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.square_grid_2x2_fill,
                                  size: 14,
                                  color: textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    order.department,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: labelSize,
                                    ),
                                  ),
                                ),
                                // const SizedBox(width: 6),
                                // if (order.footerTag.isNotEmpty) ...[
                                //   const SizedBox(height: 6),
                                //   _TagChip(text: order.footerTag),
                                // ],
                              ],
                            ),
                            const SizedBox(height: 15),
                            // Line (with danger icon)
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.exclamationmark_triangle_fill,
                                  size: 14,
                                  color: Color(0xFFE25555),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    order.line,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: metaSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // RIGHT
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // if (order.status != Status.none)
                          //   Text(
                          //     order.status.text,
                          //     style: TextStyle(
                          //       color: order.status.color,
                          //       fontWeight: FontWeight.w800,
                          //       fontSize: labelSize,
                          //     ),
                          //   ),
                          _MetaChip(
                            icon: CupertinoIcons.clock,
                            label: order.duration,
                            dense: true,
                          ),
                          const SizedBox(width: 6),
                          if (order.footerTag.isNotEmpty &&
                              order.status != Status.resolved) ...[
                            const SizedBox(height: 6),
                            _MetaChip(icon: null, label: order.footerTag),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- helpers ----

  Color _accentFor(WorkOrder o) {
    switch ((o.priority, o.status)) {
      case (Priority.high, final s) when s != Status.resolved:
        return AppColors.red; // coral red
      case (_, Status.resolved):
        return AppColors.successGreen; // coral red
      default:
        return const Color(0xFF2F6BFF); // brand blue fallback
    }
  }
}

/* ============================ Bits ============================ */

class _MetaChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool dense;

  const _MetaChip({this.icon, required this.label, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final padH = dense ? 8.0 : 10.0;
    final padV = dense ? 4.0 : 6.0;

    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1, // <- make width = child's width
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9EEF5)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Row(
            mainAxisSize: MainAxisSize.min, // <- content width
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: dense ? 12 : 14,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                softWrap: false,
                overflow: TextOverflow.fade, // avoids forcing extra width
                style: TextStyle(
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w700,
                  fontSize: dense ? 11.5 : 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Priority pill;
  final double fontSize;
  final bool uppercase;
  final bool showDot;

  const _StatusPill({
    required this.pill,
    this.fontSize = 12.5,
    this.uppercase = true,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = switch (pill) {
      Priority.high => (color: AppColors.red, label: 'High'),
    };

    final label = uppercase ? cfg.label.toUpperCase() : cfg.label;

    return Semantics(
      label: 'Status: ${cfg.label}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cfg.color, // 🔴 red background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                if (showDot)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _Dot(
                        color: Colors.white, // white dot on red bg
                        size: fontSize * 0.5,
                      ),
                    ),
                  ),
                TextSpan(
                  text: label,
                  style: TextStyle(
                    color: Colors.white, // white text on red bg
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    height: 1.1,
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

class _Dot extends StatelessWidget {
  final Color color;
  final double size;
  const _Dot({required this.color, this.size = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/* ───────────────────────── Top Tabs ───────────────────────── */

class _Tabs extends GetView<WorkOrdersManagementController> {
  const _Tabs();

  @override
  WorkOrdersManagementController get controller =>
      Get.find<WorkOrdersManagementController>();

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double tabH = isTablet ? 28 : 18;
    final double fs = isTablet ? 15 : 13.5;
    final double uThick = isTablet ? 3.5 : 3;
    final double uSide = isTablet ? 12 : 10;
    final double uGap = isTablet ? 8 : 6;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Container(
      color: primary,
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, c) {
          final count = controller.tabs.length;
          final segW = c.maxWidth / count;

          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: uGap + uThick),
                child: Row(
                  children: List.generate(count, (i) {
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => controller.setSelectedTab(i), // <- setter
                        child: SizedBox(
                          height: tabH,
                          child: Center(
                            child: Obx(() {
                              final active = controller.selectedTab.value == i;
                              return Text(
                                controller.tabs[i],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fs,
                                  fontWeight: active
                                      ? FontWeight.w900
                                      : FontWeight.w500,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Obx(() {
                final left = uSide + controller.selectedTab.value * segW;
                final width = segW - uSide * 2;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  left: left,
                  bottom: 0,
                  width: width,
                  height: uThick,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

/* ───────────────────────── Reusable bits ───────────────────────── */

class _InitialLoading extends StatelessWidget {
  const _InitialLoading();

  @override
  Widget build(BuildContext context) {
    // Simple first-load spinner; replace with shimmer if you like
    return const Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const _SearchField({this.onChanged});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    final double h = isTablet ? 52 : 44;
    final double r = isTablet ? 12 : 10;
    final double pad = isTablet ? 16 : 12;
    final double fs = isTablet ? 16 : 14;
    final double icon = isTablet ? 20 : 18;

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(color: Colors.white, fontSize: fs),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Search Work Orders',
          hintStyle: TextStyle(color: Colors.white70, fontSize: fs),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: pad, vertical: 10),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.search,
              color: Colors.white70,
              size: icon,
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minHeight: h,
            minWidth: isTablet ? 48 : 40,
          ),
        ),
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? bg;
  final Color? outline;
  const _IconSquare({
    required this.child,
    required this.onTap,
    this.bg,
    this.outline,
  });

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double size = isTablet ? 52 : 44;
    final double radius = isTablet ? 10 : 8;

    return Material(
      color: bg ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: outline ?? const Color(0xFFDFE5F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: size,
          width: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final int currentIndex;
  const BottomBar({super.key, required this.currentIndex});

  static const Color _blue = AppColors.primaryBlue;
  static const Color _grey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: primary.withOpacity(0.10),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : primary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? primary : primary,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
          );
        }),
      ),
      child: NavigationBar(
        height: 70,
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.increase_indent),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.cube_box),
            label: 'Assets',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.doc_on_clipboard),
            label: 'Work Orders',
          ),
        ],
        onDestinationSelected: (i) {
          if (i == currentIndex) return;
          switch (i) {
            case 0:
              Get.offAllNamed(Routes.homeDashboardScreen);
              break;
            case 1:
              Get.offAllNamed(Routes.homeDashboardScreen);
              break;
            case 2:
              Get.offAllNamed(Routes.assetsManagementDashboardScreen);
              break;
            case 3:
              Get.toNamed(Routes.workOrderDetailsTabScreen);
              break;
          }
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.doc_on_clipboard,
              size: 48,
              color: Color(0xFFB7C1D6),
            ),
            const SizedBox(height: 12),
            const Text(
              'No work orders found',
              style: TextStyle(
                color: Color(0xFF2D2F39),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different search',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7C8698)),
            ),
          ],
        ),
      ),
    );
  }
}
