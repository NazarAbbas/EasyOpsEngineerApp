import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// ================== MODEL ==================
class SuggestionDetail {
  final String id; // SG-112
  final String title;
  final String status; // Open
  final String category; // Cost Saving
  final String? costText; // ₹ 1,00,000
  final String department; // Banburry Department
  final DateTime createdAt; // 09 Aug 18:08

  final String suggestionText;
  final String justificationText;

  final String reporterName; // Raj Kumar
  final String reporterPhone; // +91 ...
  final String reporterDepartment; // Assets Shop

  const SuggestionDetail({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    this.costText,
    required this.department,
    required this.createdAt,
    required this.suggestionText,
    required this.justificationText,
    required this.reporterName,
    required this.reporterPhone,
    required this.reporterDepartment,
  });
}

/// ================== CONTROLLER ==================
class SuggestionDetailController extends GetxController {
  // Normally you’d pass this via arguments or fetch from API
  final detail = SuggestionDetail(
    id: 'SG-112',
    title: 'Punch Module can be added for online punches',
    status: 'Open',
    category: 'Cost Saving',
    costText: '₹ 1,00,000',
    department: 'Banburry Department',
    createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
    suggestionText:
        'Waste mindfulness quarter plane view cross cta. Working door ourselves more note crack silently deliverables performance timepoint.',
    justificationText:
        'All policy skulls nobody effects window long. Cross-pollination seems driving no will forward cob dunder already optimal.',
    reporterName: 'Raj Kumar',
    reporterPhone: '+91 9876543210',
    reporterDepartment: 'Assets Shop',
  ).obs;

  void onEdit() {
    Get.snackbar('Edit', 'Open edit form', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> callReporter() async {
    final num = detail.value.reporterPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: num);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) Get.snackbar('Failed', 'Could not open dialer');
  }
}
