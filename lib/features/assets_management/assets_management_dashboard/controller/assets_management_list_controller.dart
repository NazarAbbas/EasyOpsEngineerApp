import 'dart:ui';

import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/assets_management/assets_management_dashboard/models/area_group.dart';
import 'package:get/get.dart';

class AssetsManagementDashboardController extends GetxController {
  // Tabs / search
  final tabs = const ['All', 'Critical', 'Semi Critical', 'Non Critical'];
  final selectedTab = 0.obs;
  final query = ''.obs;

  // Groups (plants/shops)
  final groups = <AreaGroup>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitial();
  }

  void setSelectedTab(int i) => selectedTab.value = i;
  void setQuery(String v) => query.value = v;

  /// Accordion behavior: only one open at a time
  void toggle(int i) {
    for (var g = 0; g < groups.length; g++) {
      if (g == i) {
        groups[g].expanded.toggle();
      } else {
        groups[g].expanded.value = false;
      }
    }
  }

  // Handle the section row press here (navigate, filter, etc.)
  void onGroupTap(AreaGroup g) {
    // Example: show a toast or navigate
    //Get.snackbar('Group pressed', g.title, snackPosition: SnackPosition.BOTTOM);

    // Or navigate:
    // Get.toNamed(Routes.assetsGroupDetail, arguments: g);
  }

  void onAssetTap(AreaGroup group, AssetItem item) {
    // Do whatever you need here (navigate, show sheet, etc.)
    // Get.toNamed(Routes.assetDetail, arguments: {'group': group, 'item': item});
    // Get.snackbar(
    //   'Row pressed',
    //   '${group.title} • ${item.name}',
    //   snackPosition: SnackPosition.BOTTOM,
    // );
    Get.toNamed(Routes.assetsDetailsScreen);
  }

  Future<void> _loadInitial() async {
    await Future.delayed(const Duration(milliseconds: 250));

    Color pillColor(String p) {
      switch (p.toLowerCase()) {
        case 'critical':
          return const Color(0xFFEF4444);
        case 'semi critical':
          return const Color(0xFFF59E0B);
        case 'non critical':
        default:
          return const Color(0xFF10B981);
      }
    }

    List<AssetItem> sample(String brand) => [
      AssetItem(
        name: 'CNC 1',
        brand: brand,
        pill: 'Critical',
        pillColor: pillColor('Critical'),
        state: 'Working',
        description:
            'CNC Vertical Assets Center used for machining complex housings and components with high precision.',
      ),
      AssetItem(
        name: 'Hydraulic Press 1',
        brand: brand,
        pill: 'Semi Critical',
        pillColor: pillColor('Semi Critical'),
        state: 'Working',
        description:
            'Hydraulic Forming Press used to shape and mold metal sheets into parts such as brackets or panels.',
      ),
      AssetItem(
        name: 'Lathe 1',
        brand: brand,
        pill: 'Non Critical',
        pillColor: pillColor('Non Critical'),
        state: 'Working',
        description:
            'CNC Turning Lathe used for turning cylindrical parts and shafts with precise dimensions.',
      ),
    ];

    groups.assignAll([
      AreaGroup(
        title: 'Plant A | Assets Shop',
        expanded: false,
        items: sample('Siemens'),
      ),
      AreaGroup(
        title: 'Plant A | Assets Shop',
        expanded: false,
        items: sample('Fanuc'),
      ),
      AreaGroup(
        title: 'Plant A | Banburry',
        expanded: false,
        items: sample('Bosch'),
      ),
    ]);
  }
}

bool matchesTab(AssetItem it, int tabIndex) {
  final pill = it.pill.toLowerCase();
  switch (tabIndex) {
    case 0:
      return true; // All
    case 1:
      return pill == 'critical';
    case 2:
      return pill.contains('semi');
    case 3:
      return pill.contains('non');
    default:
      return true;
  }
}
