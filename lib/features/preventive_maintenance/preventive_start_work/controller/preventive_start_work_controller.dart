import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/preventive_maintenance/preventive_start_work/models/preventive_start_work.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreventiveStartWorkController extends GetxController {
  // Header
  final machineName = 'CNC-1'.obs;
  final brand = 'Siemens'.obs;
  final location = 'CNC Vertical Assets Center where we make housing'.obs;
  final severityText = 'Critical'.obs;
  final runningStatusText = 'Working'.obs;

  // Metrics
  final mtbf = '110 Days'.obs;
  final bdHours = '17 Hrs'.obs;
  final mttr = '2.4 Hrs'.obs;
  final criticality = 'Semi'.obs;

  // Preventive
  final preventiveTitle = 'Half Yearly Comprehensive\nMaintenance'.obs;
  final scheduledLine1 = 'Scheduled on 13 Mar (Thu)'.obs;
  final scheduledLine2 = '02:00 PM to 06:00 PM'.obs;
  final pendingHours = '4 Hrs required'.obs;

  // Collapses
  final scheduleAcceptedExpanded = true.obs;
  final resourcesExpanded = true.obs;
  final activitiesExpanded = true.obs;

  // People
  final acceptedBy = <AcceptedBy>[
    AcceptedBy('Production', 'Ashwath Mohan Mahendran', '+91 90000 00000'),
    AcceptedBy('Maintenance', 'Rajesh Kumar', '+91 98888 88888'),
  ].obs;

  // Resources
  final resources = <ResourceItem>[
    ResourceItem('External Man Power', 21),
    ResourceItem('Hydra', 1),
    ResourceItem('Stamping', 1),
  ].obs;

  int get identifiedResources => resources.length;

  // Activities
  final activities = <ActivityItem>[
    ActivityItem(
      title: 'Tent 30,000ft moments criticality savvy',
      code: 'AC-302',
      time: '18:08',
      date: '09 Aug',
      status: 'In Progress',
      type: 'Preventive',
      bdCode: 'BD 102',
    ),
    ActivityItem(
      title:
          'Hammer tomorrow based based club awareness growth look reality effects.',
      code: 'AC-303',
      time: '18:08',
      date: '09 Aug',
      status: 'In Progress',
      type: 'Preventive',
      bdCode: 'BD 402',
    ),
  ].obs;

  int get identifiedActivities => activities.length;

  // Actions (wire to your flows)
  void proposeNew() => Get.snackbar(
    'Propose',
    'Open propose new slot',
    snackPosition: SnackPosition.BOTTOM,
  );

  void addMoreResources() => Get.toNamed(Routes.addResourceScreen);

  // Get.snackbar(
  //   'Resources',
  //   'Add more resources',
  //   snackPosition: SnackPosition.BOTTOM,
  // );

  void addMoreActivity() => Get.snackbar(
    'Activity',
    'Add more activity',
    snackPosition: SnackPosition.BOTTOM,
  );

  void call(String phone) =>
      Get.snackbar('Calling', phone, snackPosition: SnackPosition.BOTTOM);

  void viewDetails(ActivityItem a) =>
      Get.snackbar('Details', a.bdCode, snackPosition: SnackPosition.BOTTOM);

  void closeActivity(ActivityItem a) =>
      Get.snackbar('Close', a.title, snackPosition: SnackPosition.BOTTOM);

  void otherOptions() => Get.snackbar(
    'Other Options',
    'Open options',
    snackPosition: SnackPosition.BOTTOM,
  );

  void startWork() => Get.snackbar(
    'Start Work',
    'Work started',
    snackPosition: SnackPosition.BOTTOM,
  );
}
