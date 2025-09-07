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

enum HistoryType { breakdown, preventive }

class AssetHistoryItem {
  final String date; // "09 Aug 2024"
  final HistoryType type; // Breakdown / Preventive
  final String category; // Mechanical / Scheduled
  final String description; // multiline desc
  final String assignee; // Rahul Singh
  final String duration; // "03h 20m"
  const AssetHistoryItem({
    required this.date,
    required this.type,
    required this.category,
    required this.description,
    required this.assignee,
    required this.duration,
  });
}

class AssetsHistoryController extends GetxController {
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

  // Tabs: 0=All, 1=Breakdown, 2=Preventive
  final RxInt tabIndex = 0.obs;

  // History (seeded to match screenshot)
  final RxList<AssetHistoryItem> history = <AssetHistoryItem>[
    const AssetHistoryItem(
      date: '09 Aug 2024',
      type: HistoryType.breakdown,
      category: 'Mechanical',
      description:
          'Fixed the latency Issue in web browser which was used daily and started creating problems',
      assignee: 'Rahul Singh',
      duration: '03h 20m',
    ),
    const AssetHistoryItem(
      date: '10 Jul 2024',
      type: HistoryType.preventive,
      category: 'Scheduled',
      description: 'Required Motor Rewiring, working for now.',
      assignee: 'Rahul Singh',
      duration: '08h 00m',
    ),
    const AssetHistoryItem(
      date: '09 Aug 2024',
      type: HistoryType.breakdown,
      category: 'Mechanical',
      description:
          'Fixed the latency Issue in web browser which was used daily and started creating problems',
      assignee: 'Rahul Singh',
      duration: '03h 20m',
    ),
    // add more if needed…
  ].obs;

  List<AssetHistoryItem> get visibleHistory {
    if (tabIndex.value == 1) {
      return history.where((e) => e.type == HistoryType.breakdown).toList();
    }
    if (tabIndex.value == 2) {
      return history.where((e) => e.type == HistoryType.preventive).toList();
    }
    return history;
  }

  void setTab(int i) => tabIndex.value = i;
}
