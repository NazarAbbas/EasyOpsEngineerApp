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

class ChecklistItem {
  final String title;
  final String meta; // e.g., "Monthly | Multimeter"
  final String description; // long line under info icon
  const ChecklistItem({
    required this.title,
    required this.meta,
    required this.description,
  });
}

class PMChecklistController extends GetxController {
  final Rx<AssetSummary> asset = Rx<AssetSummary>(
    const AssetSummary(
      code: 'CNC-1',
      make: 'Siemens',
      description: 'CNC Vertical Assets Center where we make housing',
      status: 'Working',
      criticality: 'Critical',
    ),
  );

  final RxList<ChecklistItem> items = <ChecklistItem>[
    const ChecklistItem(
      title: 'Check Assets cleanliness',
      meta: 'Monthly | Multimeter',
      description: 'Prevents dust buildup and ensures smooth operation.',
    ),
    const ChecklistItem(
      title: 'Inspect lubrication system',
      meta: '',
      description:
          'Ensures all moving parts are properly lubricated to avoid wear.',
    ),
    const ChecklistItem(
      title: 'Check hydraulic fluid level',
      meta: '',
      description: 'Prevents malfunctioning of hydraulic components.',
    ),
    const ChecklistItem(
      title: 'Verify coolant level and quality',
      meta: '',
      description:
          'Ensures proper cooling during operations, preventing overheating.',
    ),
  ].obs;
}
