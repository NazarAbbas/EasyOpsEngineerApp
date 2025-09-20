// features/staff/tabs/ui/staff_tabs_shell.dart
import 'package:easy_ops/features/staff/ui/current_shift_page.dart';
import 'package:easy_ops/features/staff/ui/staff_search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/staff_tabs_controller.dart';

class StaffTabsPage extends GetView<StaffTabsController> {
  const StaffTabsPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    Get.put(StaffTabsController(), permanent: true);
    final isTab = _isTablet(context);
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    final headerH = isTab ? 92.0 : 80.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: _HeaderBar(title: 'Staff', primary: primary),
      ),
      body: Column(
        children: [
          const _HeaderTabs(),
          const SizedBox(height: 6),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: controller.selectedTab.value,
                children: const [StaffCurrentShiftPage(), StaffSearchPage()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Header (compact, centered title) ---------------- */

class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color primary;
  const _HeaderBar({required this.title, required this.primary});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final isTab = _isTablet(context);
    final top = MediaQuery.of(context).padding.top;
    final rowH = isTab ? 40.0 : 36.0;
    final slot = isTab ? 44.0 : 40.0;

    return Container(
      padding: EdgeInsets.fromLTRB(12, top + 4, 12, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: slot,
            height: rowH,
            child: Material(
              color: Colors.white.withOpacity(0.16),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: Get.back,
                child: Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                  size: isTab ? 20 : 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTab ? 17 : 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          SizedBox(width: slot, height: rowH), // mirror left slot
        ],
      ),
    );
  }
}

/* ---------------- Tabs (Current Shift / Search) ---------------- */

class _HeaderTabs extends GetView<StaffTabsController> {
  const _HeaderTabs();

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.of(context).size.shortestSide >= 600;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final tabH = isTab ? 34.0 : 30.0;
    final fs = isTab ? 14.0 : 13.0;

    return Container(
      color: primary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: LayoutBuilder(
        builder: (context, c) {
          final segW = c.maxWidth / 2;
          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.setTab(0),
                      child: SizedBox(
                        height: tabH,
                        child: Center(
                          child: Obx(() {
                            final active = controller.selectedTab.value == 0;
                            return Text(
                              'Current Shift',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fs,
                                fontWeight: active
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.setTab(1),
                      child: SizedBox(
                        height: tabH,
                        child: Center(
                          child: Obx(() {
                            final active = controller.selectedTab.value == 1;
                            return Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: fs,
                                fontWeight: active
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                final left = controller.selectedTab.value * segW;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: left + (segW * 0.18),
                  bottom: 0,
                  width: segW * 0.64,
                  height: 2.6,
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
