// lib/core/navigation/main_tab_shell.dart
import 'package:easy_ops/features/assets_management/assets_management_dashboard/ui/assets_management_dashboard_page.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/home_dashboard/ui/home_dashboard_page.dart';
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/ui/work_order_management_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/landing_dashboard_nav_controller.dart';

class LandingDashboardTabShell extends StatefulWidget {
  const LandingDashboardTabShell({super.key});

  @override
  State<LandingDashboardTabShell> createState() =>
      _LandingDashboardTabShellState();
}

class _LandingDashboardTabShellState extends State<LandingDashboardTabShell> {
  late final PageController _pageController;
  final c = Get.find<LandingRootNavController>(); // don't put() here

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    final startTab = (arg is Map && arg['tab'] is int)
        ? arg['tab'] as int
        : c.index.value;

    _pageController = PageController(initialPage: startTab);

    // keep GetX index in sync with initial page
    if (c.index.value != startTab) {
      c.setIndex(startTab);
    }

    // (Optional) listen to page changes if you ever enable swiping
    // _pageController.addListener(() {
    //   final p = _pageController.page?.round() ?? 0;
    //   if (p != c.index.value) c.setIndex(p);
    // });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i == c.index.value) return;
    c.setIndex(i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        key: const PageStorageKey('landing-shell'), // defensive
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeDashboardPage(key: PageStorageKey('tab-0-home')),
          HomeDashboardPage(key: PageStorageKey('tab-1-inventory')),
          AssetsManagementDashboardPage(key: PageStorageKey('tab-2-assets')),
          WorkOrdersManagementListPage(key: PageStorageKey('tab-3-workorders')),
        ],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: c.index.value,
          onDestinationSelected: _select,
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
        ),
      ),
    );
  }
}
