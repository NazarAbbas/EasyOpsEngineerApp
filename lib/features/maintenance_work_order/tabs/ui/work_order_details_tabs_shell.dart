// The screen with header tabs + body that swaps content
import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/features/maintenance_work_order/WorkTabsController.dart';
import 'package:easy_ops/features/maintenance_work_order/accept_work_order/ui/accept_work_order_page.dart';
import 'package:easy_ops/features/maintenance_work_order/history/ui/history_page.dart';
import 'package:easy_ops/features/maintenance_work_order/timeline/ui/timeline_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkOrderDetailsTabsShell extends StatelessWidget {
  const WorkOrderDetailsTabsShell({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WorkTabsController());
    final isTablet = _isTablet(context);
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 140 : 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.fromLTRB(12, isTablet ? 14 : 10, 12, 8),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Back + centered title
                Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Text(
                        'Work Order Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 22 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // balance IconButton width
                  ],
                ),
                const SizedBox(height: 6),
                const _HeaderTabs(),
              ],
            ),
          ),
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: ctrl.selectedTab.value, // 0 shows WorkOrderInfoPage first
          children: [
            const AcceptWorkOrderPage(),
            const HistoryPage(),
            const TimelinePage(),
          ],
        ),
      ),
    );
  }
}

class _HeaderTabs extends GetView<WorkTabsController> {
  const _HeaderTabs();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final segW = c.maxWidth / controller.tabs.length;
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: List.generate(controller.tabs.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.selectedTab.value = i,
                      child: SizedBox(
                        height: 38,
                        child: Center(
                          child: Obx(() {
                            final active = controller.selectedTab.value == i;
                            return Text(
                              controller.tabs[i],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: active
                                    ? FontWeight.w700
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
            // underline
            Obx(() {
              final left = 8 + controller.selectedTab.value * segW;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: left,
                bottom: 0,
                width: segW - 16,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
