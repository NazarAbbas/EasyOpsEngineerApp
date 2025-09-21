// ignore_for_file: deprecated_member_use

import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/feature_general_work_order/general_work_order_list/controller/general_work_order_list_controller.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/maintenance_wotk_order_management/controller/work_order_management_controller.dart'
    hide MarkerEvent;
import 'package:easy_ops/features/feature_maintenance_work_order/maintenance_wotk_order_management/models/work_order.dart'
    hide WorkOrder;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class GeneralWorkOrderListPage extends GetView<GeneralWorkOrderListController> {
  const GeneralWorkOrderListPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
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
      // bottomNavigationBar: const BottomBar(currentIndex: 2),
    );
  }
}

/* ───────────────────────── Header ───────────────────────── */

/* ───────────────────────── Header (drop-in) ───────────────────────── */

class _GradientHeader extends GetView<GeneralWorkOrderListController>
    implements PreferredSizeWidget {
  const _GradientHeader();

  @override
  GeneralWorkOrderListController get controller =>
      Get.find<GeneralWorkOrderListController>();

  @override
  Size get preferredSize => const Size.fromHeight(120);

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final isTablet = _isTablet(context);

    // Consistent layout constants
    final double hPad = isTablet ? 16 : 16; // left/right padding
    final double vPadTop = isTablet
        ? 8
        : 8; // top content padding (below status bar)
    final double vPadBottom = isTablet ? 12 : 12;
    final double titleRowH = isTablet
        ? 40
        : 36; // back button/tap target height
    final double gap = isTablet ? 12 : 12; // uniform horizontal gaps

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
      padding: EdgeInsets.fromLTRB(hPad, top + vPadTop, hPad, vPadBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title row: fixed-width left & right slots ensure perfect centering
          SizedBox(
            height: titleRowH,
            child: Row(
              children: [
                // Center: title (Expanded + Center ensures perfect centering)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Work Order Management',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                // Right slot: fixed width placeholder to mirror left
                SizedBox(width: titleRowH, height: titleRowH),
              ],
            ),
          ),

          SizedBox(height: gap),

          // ── Search + Actions with equal gaps between items
          Row(
            children: [
              Expanded(child: _SearchField(onChanged: controller.setQuery)),
              SizedBox(width: gap),
              _IconSquare(
                onTap: () {
                  Get.dialog(
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
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
              SizedBox(width: gap),
              _IconSquare(
                onTap: () {
                  // TODO: Create action
                },
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

class _CalendarCard extends GetView<GeneralWorkOrderListController> {
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

class _WorkOrderCard extends GetView<GeneralWorkOrderListController> {
  final WorkOrder order;
  const _WorkOrderCard({required this.order});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    // — compact scale —
    final double r = isTablet ? 14 : 12;
    final double pad = isTablet ? 14 : 12;
    final double titleFs = isTablet ? 16 : 14.5;
    final double metaFs = isTablet ? 12.5 : 11.5;
    final double lineFs = isTablet ? 12.5 : 11.5;
    final double statusFs = isTablet ? 12.5 : 11.5;

    // — palette —
    const border = Color(0xFFE8ECF3);
    const title = Color(0xFF1F2430);
    const muted = Color(0xFF808A98);
    const status = Color(0xFF1E4FD6);
    const warn = Color(0xFFE53935);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: border),
        boxShadow: [
          // ultra subtle elevation
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(r),
          onTap: () {
            controller.goToAnotherScreen(order);
            // if (order.status.name == 'resolved') {
            //   Get.toNamed(Routes.updateWorkOrderTabScreen, arguments: order);
            // } else {
            //   Get.toNamed(Routes.workOrderDetailsTabScreen, arguments: order);
            // }
          },
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: title,
                          fontSize: titleFs,
                          fontWeight: FontWeight.w800,
                          height: 1.22,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.status.text, // e.g. In Progress
                      style: TextStyle(
                        color: status,
                        fontSize: statusFs,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 8 : 6),

                // GM-998  •  18:08 | 09 Aug
                Row(
                  children: [
                    _meta(order.code, metaFs, muted),
                    _sepDot(muted),
                    _meta(order.time, metaFs, muted),
                    _sepPipe(muted),
                    _meta(order.date, metaFs, muted),
                  ],
                ),

                SizedBox(height: isTablet ? 8 : 6),

                // ⚠︎ CNC - 1
                Row(
                  children: [
                    Icon(Icons.warning_rounded, size: metaFs + 2, color: warn),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.line, // "CNC - 1"
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: title,
                          fontSize: lineFs,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(String t, double fs, Color c) => Text(
    t,
    style: TextStyle(
      color: c,
      fontSize: fs,
      fontWeight: FontWeight.w800,
      height: 1.1,
    ),
  );

  Widget _sepDot(Color c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      width: 3.2,
      height: 3.2,
      decoration: BoxDecoration(
        color: c.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
    ),
  );

  Widget _sepPipe(Color c) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Text(
      '|',
      style: TextStyle(color: c.withOpacity(0.6), fontWeight: FontWeight.w700),
    ),
  );
}

class _Tabs extends GetView<GeneralWorkOrderListController> {
  const _Tabs();

  @override
  GeneralWorkOrderListController get controller =>
      Get.find<GeneralWorkOrderListController>();

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
              Get.toNamed(Routes.homeDashboardScreen);
              break;
            case 1:
              //Get.offAllNamed(Routes.homeDashboardScreen);
              break;
            case 2:
              Get.toNamed(Routes.assetsManagementDashboardScreen);
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
