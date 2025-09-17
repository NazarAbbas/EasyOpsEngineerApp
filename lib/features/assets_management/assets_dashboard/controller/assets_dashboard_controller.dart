import 'package:easy_ops/features/assets_management/assets_dashboard/ui/assets_dashboard_page.dart';
import 'package:get/get.dart';

class AssetSummary {
  final String code;
  final String make;
  final String description;
  final String status; // e.g., Working
  final String criticality; // e.g., Critical / Semi

  AssetSummary({
    required this.code,
    required this.make,
    required this.description,
    required this.status,
    required this.criticality,
  });
}

class MetricItem {
  final String label; // e.g., MTBF
  final String value; // e.g., 110 Days
  MetricItem({required this.label, required this.value});
}

// class ChartPoint {
//   final String x; // label (month)
//   final double y;
//   ChartPoint(this.x, this.y);
// }

class AssetsDashboardController extends GetxController {
  final Rx<AssetSummary> asset = Rx<AssetSummary>(
    AssetSummary(
      code: 'CNC-1',
      make: 'Siemens',
      description: 'CNC Vertical Assets Center where we make housing',
      status: 'Working',
      criticality: 'Critical',
    ),
  );

  final RxList<MetricItem> metrics = <MetricItem>[
    MetricItem(label: 'MTBF', value: '110 Days'),
    MetricItem(label: 'BD Hours', value: '17 Hrs'),
    MetricItem(label: 'MTTR', value: '2.4 Hrs'),
    MetricItem(label: 'Criticality', value: 'Semi'),
  ].obs;

  final RxList<ChartPoint> breakdownHrs = <ChartPoint>[
    ChartPoint('Jan', 200),
    ChartPoint('Feb', 320),
    ChartPoint('Mar', 910),
    ChartPoint('Apr', 450),
    ChartPoint('May', 980),
    ChartPoint('Jun', 980),
    ChartPoint('Jul', 860),
    ChartPoint('Aug', 210),
    ChartPoint('Sep', 720),
    ChartPoint('Oct', 260),
    ChartPoint('Nov', 640),
    ChartPoint('Dec', 680),
  ].obs;

  final RxList<ChartPoint> sparesConsumption = <ChartPoint>[
    ChartPoint('Jan', 200),
    ChartPoint('Feb', 4200),
    ChartPoint('Mar', -5200),
    ChartPoint('Apr', 800),
    ChartPoint('May', 1200),
    ChartPoint('Jun', -600),
    ChartPoint('Jul', 900),
    ChartPoint('Aug', 1100),
    ChartPoint('Sep', -300),
    ChartPoint('Oct', 500),
    ChartPoint('Nov', 700),
    ChartPoint('Dec', 900),
  ].obs;

  // Optional hooks you can wire later
  void onStatusTap() {}
  void onHeaderTap() {}
}
