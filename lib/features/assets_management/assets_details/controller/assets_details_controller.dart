import 'package:easy_ops/core/route_management/routes.dart';
import 'package:get/get.dart';

class AssetsDetailController extends GetxController {
  // Page
  final pageTitle = 'Assets Detail'.obs;

  // ── Dashboard KPIs
  final mtbf = '110 Days'.obs;
  final bdHours = '17 Hrs'.obs;
  final mttr = '2.4 Hrs'.obs;
  final criticality = 'Semi'.obs;

  // ── Asset spec
  final assetName = 'CNC-1'.obs;
  final brand = 'Siemens'.obs;
  final priority = 'Critical'.obs; // Critical / Medium / Low
  final description = 'CNC Vertical Assets Center where we make housing'.obs;
  final runningState = 'Working'.obs;

  // ── Manufacturer contact
  final phone = '+91 98739 00959'.obs;
  final email = 'support@siemens.com'.obs;
  final address =
      'Shop No 402, GNOU Road, Opposite Gali No 4, IGNOU Main Road, Neb Sarai, New Delhi (110068)'
          .obs;
  final hours = const [
    ('Monday - Friday', '8:30 AM - 8 PM'),
    ('Saturday', '8:30 AM - 2 PM'),
  ].obs;

  // ── PM schedule
  final pmType = 'Preventive'.obs;
  final pmTitle = 'Half Yearly Comprehensive Maintenance'.obs;
  final pmWhen = '12 Aug (Wed)\n12:00 PM to 14:00 PM'.obs;
  final pmStatusRightTitle = 'Approved'.obs;

  // ── History (last item preview)
  final histDate = '09 Aug 2024'.obs;
  final histType = 'Breakdown'.obs;
  final histDept = 'Mechanical'.obs;
  final histText =
      'Fixed the latency Issue in web browser which was used daily and started creating problems'
          .obs;
  final histUser = 'Rahul Singh'.obs;
  final histDuration = '03h 20m'.obs;

  // ── Actions (wire up your real flows here)
  void onViewMore(String section) => {
    if (section == "Assets Specification")
      {Get.toNamed(Routes.assetsSpecificationScreen)}
    else if (section == "Assets Dashboard")
      {Get.toNamed(Routes.assetsDashboardScreen)}
    else if (section == "PM Schedule")
      {Get.toNamed(Routes.assetsPMSchedular)}
    else if (section == "Assets History")
      {Get.toNamed(Routes.assetsHistoryScreen)},
  };

  void callPhone() =>
      Get.snackbar('Call', phone.value, snackPosition: SnackPosition.BOTTOM);
  void emailSupport() =>
      Get.snackbar('Email', email.value, snackPosition: SnackPosition.BOTTOM);
  void openMap() => Get.snackbar(
    'Map',
    'Open address in maps',
    snackPosition: SnackPosition.BOTTOM,
  );

  void viewActivities() => Get.snackbar(
    'PM',
    'View Activities',
    snackPosition: SnackPosition.BOTTOM,
  );
  void proposeNew() =>
      Get.snackbar('PM', 'Propose New', snackPosition: SnackPosition.BOTTOM);
  void viewChecklist() => {Get.toNamed(Routes.pMCheckListScreen)};
}
