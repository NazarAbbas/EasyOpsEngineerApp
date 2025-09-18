// lib/core/navigation/main_tab_shell.dart
import 'package:easy_ops/features/assets_management/assets_management_dashboard/ui/assets_management_dashboard_page.dart';
import 'package:easy_ops/features/dashboard_screens/preventive_dashboard/controller/preventive_dashboard_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/preventive_work_order_list/ui/preventive_work_order_list_page.dart';
import 'package:easy_ops/features/spare_parts/tabs/ui/spare_parts_tabs_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreventiveDashboardPage extends StatelessWidget {
  const PreventiveDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PreventiveRootNavController(), permanent: true);

    // Titles shown in the AppBar per tab
    const titles = <String>['Home', 'Spare Parts', 'Assets', 'Work Orders'];

    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   // Show back button only if this page is not the root
      //   leading: Navigator.of(context).canPop()
      //       ? IconButton(
      //           icon: const Icon(CupertinoIcons.chevron_back),
      //           onPressed: Get.back,
      //           tooltip: 'Back',
      //         )
      //       : null,
      //   // Dynamic title based on selected tab
      //   //title: Obx(() => Text(titles[c.index.value])),
      //   title: Text('Preventive Maintenance'),
      // ),
      body: PageView(
        controller: c.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          PreventiveWorkOrderListPage(),
          SparePartsTabsShell(),
          AssetsManagementDashboardPage(),
          PreventiveWorkOrderListPage(),
          // PreventiveWorkOrderPage(), // your existing page
        ],
      ),

      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: c.index.value,
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
          onDestinationSelected: c.select, // uses your controller's jumpToPage
        ),
      ),
    );
  }
}
