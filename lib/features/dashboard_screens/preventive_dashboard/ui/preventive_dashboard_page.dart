// lib/core/navigation/main_tab_shell.dart
import 'package:easy_ops/features/assets_management/assets_management_dashboard/ui/assets_management_dashboard_page.dart';
import 'package:easy_ops/features/dashboard_screens/preventive_dashboard/controller/preventive_dashboard_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/preventive_work_order_list/ui/preventive_work_order_list_page.dart';
import 'package:easy_ops/features/spare_parts/tabs/ui/spare_parts_tabs_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/home_dashboard/ui/home_dashboard_page.dart';
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/ui/work_order_management_list_page.dart';

class PreventiveDashboardPage extends StatefulWidget {
  const PreventiveDashboardPage({super.key});

  @override
  State<PreventiveDashboardPage> createState() => _PreventiveDashboardPage();
}

class _PreventiveDashboardPage extends State<PreventiveDashboardPage> {
  late final PageController _pageController;
  final c = Get.find<PreventiveRootNavController>(); // don't put() here

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
          PreventiveWorkOrderListPage(key: PageStorageKey('tab-0-home')),
          SparePartsTabsShell(key: PageStorageKey('tab-1-spareparts')),
          AssetsManagementDashboardPage(key: PageStorageKey('tab-2-assets')),
          PreventiveWorkOrderListPage(key: PageStorageKey('tab-3-workorders')),
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
        ),
      ),
    );
  }
}

// class PreventiveDashboardPage extends StatelessWidget {
//   const PreventiveDashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final c = Get.put(PreventiveRootNavController(), permanent: true);

//     // Titles shown in the AppBar per tab
//     const titles = <String>['Home', 'Spare Parts', 'Assets', 'Work Orders'];

//     return Scaffold(
//       body: PageView(
//         controller: c.pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: const [
//           PreventiveWorkOrderListPage(),
//           SparePartsTabsShell(),
//           AssetsManagementDashboardPage(),
//           PreventiveWorkOrderListPage(),
//         ],
//       ),

//       bottomNavigationBar: Obx(
//         () => NavigationBar(
//           selectedIndex: c.index.value,
//           destinations: const [
//             NavigationDestination(
//               icon: Icon(CupertinoIcons.house),
//               label: 'Home',
//             ),
//             NavigationDestination(
//               icon: Icon(CupertinoIcons.increase_indent),
//               label: 'Spare Parts',
//             ),
//             NavigationDestination(
//               icon: Icon(CupertinoIcons.cube_box),
//               label: 'Assets',
//             ),
//             NavigationDestination(
//               icon: Icon(CupertinoIcons.doc_on_clipboard),
//               label: 'Work Orders',
//             ),
//           ],
//           onDestinationSelected: c.select, // uses your controller's jumpToPage
//         ),
//       ),
//     );
//   }
// }
