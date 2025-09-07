import 'package:get/get.dart';

class AssetSummary {
  final String code;
  final String make;
  final String description;
  final String status; // Working
  final String criticality; // Critical
  const AssetSummary({
    required this.code,
    required this.make,
    required this.description,
    required this.status,
    required this.criticality,
  });
}

class MetricItem {
  final String label; // MTBF
  final String value; // 110 Days
  const MetricItem({required this.label, required this.value});
}

class UpcomingPM {
  final String type; // Preventive
  final String status; // Pending
  final String title; // Half Yearly Comprehensive Maintenance
  final String dueBy; // 05 Jan, 2025
  const UpcomingPM({
    required this.type,
    required this.status,
    required this.title,
    required this.dueBy,
  });
}

class PMHistoryItem {
  final String date; // 30 Oct, 2024
  final String type; // Preventive
  final bool completed; // true
  final String title; // Quarterly CNC Assets Calibration...
  final String assignee; // Suresh
  const PMHistoryItem({
    required this.date,
    required this.type,
    required this.completed,
    required this.title,
    required this.assignee,
  });
}

class PMScheduleController extends GetxController {
  // Header
  final Rx<AssetSummary> asset = Rx<AssetSummary>(
    const AssetSummary(
      code: 'CNC-1',
      make: 'Siemens',
      description: 'CNC Vertical Assets Center where we make housing',
      status: 'Working',
      criticality: 'Critical',
    ),
  );

  // Metrics
  final RxList<MetricItem> metrics = <MetricItem>[
    const MetricItem(label: 'MTBF', value: '110 Days'),
    const MetricItem(label: 'BD Hours', value: '17 Hrs'),
    const MetricItem(label: 'MTTR', value: '2.4 Hrs'),
    const MetricItem(label: 'Criticality', value: 'Semi'),
  ].obs;

  // Upcoming PM
  final Rx<UpcomingPM> upcoming = Rx<UpcomingPM>(
    const UpcomingPM(
      type: 'Preventive',
      status: 'Pending',
      title: 'Half Yearly Comprehensive Maintenance',
      dueBy: '05 Jan, 2025',
    ),
  );

  // History list
  final RxList<PMHistoryItem> history = <PMHistoryItem>[
    const PMHistoryItem(
      date: '30 Oct, 2024',
      type: 'Preventive',
      completed: true,
      title: 'Quarterly CNC Assets Calibration and alignment check',
      assignee: 'Suresh',
    ),
    const PMHistoryItem(
      date: '24 Feb 2024',
      type: 'Preventive',
      completed: true,
      title: 'Monthly Inspection of spindle and bearing wear',
      assignee: 'Suresh',
    ),
  ].obs;

  // Tap handlers
  void onViewActivities() {}
  void onSeeDetails(PMHistoryItem item) {}
}
