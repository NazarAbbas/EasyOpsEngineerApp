// ignore_for_file: deprecated_member_use

import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/feature_preventive_maintenance/preventive_work_order_list/controller/preventive_work_order_list_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/preventive_maintenance_dashboard_model.dart';

class PreventiveWorkOrderListPage
    extends GetView<PreventiveWorkOrderListController> {
  const PreventiveWorkOrderListPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double headerH = isTablet ? 148 : 120;
    final double hPad = isTablet ? 16 : 12;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: const _GradientHeader(),
      ),
      body: Column(
        children: [
          const _Tabs(),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const _InitialLoading();
              }

              final List<PreventiveMaintenanceDashboardModel> data =
                  controller.visibleOrders;
              if (data.isEmpty) {
                return _EmptyState(onCreate: () {});
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
                  itemBuilder: (_, i) {
                    final o = data[i];
                    return _WorkOrderCard(
                      order: o,
                      onTap: () {
                        Get.toNamed(Routes.preventiveWorkOrderScreen);
                        // final r = _routeForTitle(o.title);
                        // if (r != null) {
                        //   Get.toNamed(r, arguments: {'order': o});
                        // } else {
                        //   Get.snackbar(
                        //     'No screen mapped',
                        //     'No route mapping for "${o.title}"',
                        //     snackPosition: SnackPosition.BOTTOM,
                        //   );
                        // }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      // 👇 Add the button above bottom bar
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // TODO: Navigate to Create Work Order Screen
                  // Get.toNamed(Routes.createWorkOrderScreen);
                },
                icon: const Icon(
                  CupertinoIcons.plus,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Create Work Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          //  const BottomBar(currentIndex: 0), // 👈 Keep your bottom bar here
        ],
      ),
    );
  }
}

/* ───────────────────────── Header ───────────────────────── */

/* ───────────────────────── Header (drop-in) ───────────────────────── */

class _GradientHeader extends GetView<PreventiveWorkOrderListController>
    implements PreferredSizeWidget {
  const _GradientHeader();

  @override
  PreventiveWorkOrderListController get controller =>
      Get.find<PreventiveWorkOrderListController>();

  @override
  Size get preferredSize => const Size.fromHeight(120);

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final isTablet = _isTablet(context);

    // Consistent layout constants
    final double hPad = 16;
    final double vPadTop = 8;
    final double vPadBottom = 12;
    final double titleRowH = isTablet ? 40 : 36; // back button tap area
    final double gap = 12;

    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    final canPop = Navigator.of(context).canPop();

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
          // Title row: left & right fixed slots keep title perfectly centered
          SizedBox(
            height: titleRowH,
            child: Row(
              children: [
                // Left slot (back button if canPop)
                SizedBox(
                  width: titleRowH,
                  height: titleRowH,
                  child: canPop
                      ? Material(
                          color: Colors.white.withOpacity(0.15),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: Get.back,
                            child: const Icon(
                              CupertinoIcons.chevron_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Centered title
                const Expanded(
                  child: Center(
                    child: Text(
                      'Preventive Maintenance',
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

                // Right placeholder mirrors left width
                SizedBox(width: titleRowH, height: titleRowH),
              ],
            ),
          ),

          SizedBox(height: gap),

          // Search + Calendar + Add with equal spacing
          Row(
            children: [
              Expanded(child: _SearchField(onChanged: controller.setQuery)),
              SizedBox(width: gap),
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
              SizedBox(width: gap),
              _IconSquare(
                onTap: () {
                  // TODO: Add create action if needed
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

class _CalendarCard extends GetView<PreventiveWorkOrderListController> {
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

/* ───────────────────────── List item (Card) ───────────────────────── */
class _WorkOrderCard extends StatelessWidget {
  final PreventiveMaintenanceDashboardModel order;
  final VoidCallback? onTap; // 👈 add this
  const _WorkOrderCard({required this.order, this.onTap});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double radius = isTablet ? 16 : 12;
    final double pad = isTablet ? 16 : 14;

    return InkWell(
      // 👈 makes the whole row tappable
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: Color(0xFFE9EEF5), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Critical pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap:
                          onTap, // 👈 if you want only title to react, keep this and remove InkWell above
                      child: Text(
                        order.title,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CriticalPill(priority: order.priority),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                order.machineLine,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: isTablet ? 14 : 13,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                order.scheduleLine1,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (order.scheduleLine2 != null) ...[
                const SizedBox(height: 2),
                Text(
                  order.scheduleLine2!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.status.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: order.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    order.durationLine,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
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

/* Critical pill widget */
class _CriticalPill extends StatelessWidget {
  final Priority priority;
  const _CriticalPill({required this.priority});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: priority == Priority.high ? Colors.red : Colors.grey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          "Critical",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/* ───────────────────────── Top Tabs ───────────────────────── */

class _Tabs extends GetView<PreventiveWorkOrderListController> {
  const _Tabs();

  @override
  PreventiveWorkOrderListController get controller =>
      Get.find<PreventiveWorkOrderListController>();

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
                        onTap: () => controller.setSelectedTab(i),
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

/* ───────────────────────── Bottom Navigation ───────────────────────── */

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
            label: 'Spare Parts',
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
              Get.toNamed(Routes.sparePartsTabsShellScreen);
              break;
            case 2:
              Get.offAllNamed(Routes.assetsManagementDashboardScreen);
              break;
            case 3:
              Get.toNamed(Routes.preventiveWorkOrderScreen);
              break;
          }
        },
      ),
    );
  }
}

/* ───────────────────────── Empty State ───────────────────────── */

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
          children: const [
            Icon(
              CupertinoIcons.doc_on_clipboard,
              size: 48,
              color: Color(0xFFB7C1D6),
            ),
            SizedBox(height: 12),
            Text(
              'No work orders found',
              style: TextStyle(
                color: Color(0xFF2D2F39),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
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
