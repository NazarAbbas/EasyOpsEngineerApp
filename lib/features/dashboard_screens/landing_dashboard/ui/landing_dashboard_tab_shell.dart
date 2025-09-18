// lib/core/navigation/main_tab_shell.dart
import 'package:easy_ops/features/assets_management/assets_management_dashboard/ui/assets_management_dashboard_page.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/home_dashboard/ui/home_dashboard_page.dart';
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/ui/work_order_management_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/landing_dashboard_nav_controller.dart';

class LandingDashboardTabShell extends StatelessWidget {
  const LandingDashboardTabShell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LandingRootNavController(), permanent: true);

    return Scaffold(
      //appBar: AppBar(centerTitle: true, title: Text('Work Order Maintenance')),
      body: PageView(
        controller: c.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeDashboardPage(),
          HomeDashboardPage(),
          AssetsManagementDashboardPage(),
          WorkOrdersManagementListPage(),
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
          onDestinationSelected: c.select, // safe: guards hasClients
        ),
      ),
    );
  }
}
