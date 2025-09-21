// ==================== CONTROLLER (update) ====================
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:get/get.dart';

enum StatTone { neutral, critical, warning, success, info }

class StatItem {
  final String label;
  final int value;
  final StatTone tone;
  final bool isAction;
  const StatItem({
    required this.label,
    required this.value,
    this.tone = StatTone.neutral,
    this.isAction = false,
  });
}

class SectionStats {
  final String title;
  final RxList<StatItem> items;
  SectionStats({required this.title, required List<StatItem> initial})
    : items = RxList<StatItem>(initial);
}

class HomeDashboardController extends GetxController {
  // Work Orders (top row)
  final summary = SectionStats(
    title: 'Work Orders',
    initial: const [
      StatItem(label: 'All', value: 12, tone: StatTone.info),
      StatItem(label: 'Breakdown', value: 12, tone: StatTone.neutral),
      StatItem(label: 'Preventive', value: 3, tone: StatTone.neutral),
      StatItem(label: 'General', value: 1, tone: StatTone.neutral),
    ],
  ).obs;

  final breakdown = SectionStats(
    title: 'Breakdown',
    initial: const [
      StatItem(label: 'Open', value: 6, tone: StatTone.info),
      StatItem(label: 'Critical', value: 1, tone: StatTone.critical),
      StatItem(label: 'Escalated', value: 1, tone: StatTone.warning),
      StatItem(
        label: 'Create New',
        value: 0,
        tone: StatTone.info,
        isAction: true,
      ),
    ],
  ).obs;

  final preventive = SectionStats(
    title: 'Preventive',
    initial: const [
      StatItem(label: 'Approved', value: 3, tone: StatTone.info),
      StatItem(label: 'Overdue', value: 1, tone: StatTone.critical),
      StatItem(label: 'Pending', value: 4, tone: StatTone.warning),
      StatItem(label: 'Completed', value: 1, tone: StatTone.success),
    ],
  ).obs;

  final assets = SectionStats(
    title: 'Assets',
    initial: const [
      StatItem(label: 'Total', value: 47, tone: StatTone.info),
      StatItem(label: 'Critical', value: 5, tone: StatTone.critical),
      StatItem(label: 'Semi Critical', value: 20, tone: StatTone.warning),
      StatItem(label: 'Non Critical', value: 25, tone: StatTone.neutral),
    ],
  ).obs;

  // ==== NEW SECTION: My Team ====
  final myTeam = SectionStats(
    title: 'My Team',
    initial: const [
      StatItem(label: 'Total', value: 47, tone: StatTone.info),
      StatItem(label: 'Absent', value: 5, tone: StatTone.critical),
      StatItem(label: 'Present', value: 42, tone: StatTone.success),
      // (leave 4th slot empty by design or add another tile if you wish)
    ],
  ).obs;

  void onTileTap(SectionStats section, StatItem item) {
    if (section.title == 'Work Orders') {
      if (item.label == 'All') {
        // Get.toNamed(Routes.workOrdersAll);
        return;
      }
      if (item.label == 'Breakdown') {
        // Get.toNamed(Routes.workOrdersBreakdown);
        return;
      }
    }
    if (item.isAction) {
      // Get.toNamed(Routes.createWorkOrder);
      return;
    }
    // Get.toNamed(Routes.workOrders, arguments: {'section': section.title, 'filter': item.label});
  }

  void onSummeryHeaderTap(String title) {
    if (title == 'Work Orders') {
      Get.toNamed(Routes.generalWorkOrderScreen);
      // Get.offAllNamed(
      //   Routes.landingDashboardScreen,
      //   arguments: {'tab': 3},
      // );
    } else if (title == 'Breakdown') {
      //Get.toNamed(Routes.preventiveDashboardScreen);
    } else if (title == 'Preventive') {
      Get.toNamed(Routes.preventiveDashboardScreen);
    } else if (title == 'My Team') {
      Get.toNamed(Routes.staffScreen);
    } else if (title == 'Dashboard') {
      Get.toNamed(Routes.myDashboardScreen);
    } else if (title == 'Assets') {
      Get.offAllNamed(
        Routes.landingDashboardScreen,
        arguments: {'tab': 2}, // open Work Orders
      );
    }
  }

  void signOut() {
    // Implement your sign-out logic
  }

  // in HomeDashboardController
  final months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final breakdownHrs = <double>[0, 200, 400, 600, 800, 1000].obs;

  double get breakdownAvg => breakdownHrs.isEmpty
      ? 0
      : breakdownHrs.reduce((a, b) => a + b) / breakdownHrs.length;
}
