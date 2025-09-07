// suggestion_controller.dart
import 'package:easy_ops/route_managment/routes.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Suggestion {
  final String id;
  final String title;
  final String category;
  final String? costText;
  final String department;
  final String status; // e.g. "Open"
  final DateTime createdAt;

  // Expanded content
  final String suggestionText;
  final String justificationText;

  // NEW: reporter info
  final String reporterName;
  final String reporterPhone;
  final String reporterDepartment;

  const Suggestion({
    required this.id,
    required this.title,
    required this.category,
    this.costText,
    required this.department,
    required this.status,
    required this.createdAt,
    this.suggestionText = '',
    this.justificationText = '',
    required this.reporterName,
    required this.reporterPhone,
    required this.reporterDepartment,
  });
}

class SuggestionsController extends GetxController {
  final items = <Suggestion>[
    Suggestion(
      id: 'SG-112',
      title: 'Punch Module can be added for online punches',
      category: 'Cost Saving',
      costText: '₹ 1,00,000',
      department: 'Banburry Department',
      status: 'Open',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      suggestionText:
          'Waste mindfulness quarter plane view cross cta. Working door ourselves more note crack silently deliverables performance timepoint.',
      justificationText:
          'All policy skulls nobody effects window long. Cross-pollination seems driving no will forward cob dunder already optimal.',
      reporterName: 'Raj Kumar',
      reporterPhone: '+91 9876543210',
      reporterDepartment: 'Assets Shop',
    ),
    Suggestion(
      id: 'SG-113',
      title: 'Punch Module can be added for online punches',
      category: 'Cost Saving',
      costText: '₹ 1,00,000',
      department: 'Banburry Department',
      status: 'Open',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      suggestionText:
          'Waste mindfulness quarter plane view cross cta. Working door ourselves more note crack silently deliverables performance timepoint.',
      justificationText:
          'All policy skulls nobody effects window long. Cross-pollination seems driving no will forward cob dunder already optimal.',
      reporterName: 'Raj Kumar',
      reporterPhone: '+91 9876543210',
      reporterDepartment: 'Assets Shop',
    ),
    Suggestion(
      id: 'SG-114',
      title: 'Punch Module can be added for online punches',
      category: 'Cost Saving',
      costText: '₹ 1,00,000',
      department: 'Banburry Department',
      status: 'Open',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      suggestionText:
          'Waste mindfulness quarter plane view cross cta. Working door ourselves more note crack silently deliverables performance timepoint.',
      justificationText:
          'All policy skulls nobody effects window long. Cross-pollination seems driving no will forward cob dunder already optimal.',
      reporterName: 'Raj Kumar',
      reporterPhone: '+91 9876543210',
      reporterDepartment: 'Assets Shop',
    ),
    // ...more items
  ].obs;

  /// expanded state per suggestion id
  final expanded = <String, bool>{}.obs;
  bool isOpen(String id) => expanded[id] ?? false;
  void toggleOpen(String id) {
    expanded[id] = !(expanded[id] ?? false);
    expanded.refresh();
  }

  void openSuggestion(Suggestion s) {
    // Optionally navigate to detail page
    // Get.to(() => const SuggestionDetailPage(), arguments: s);
  }

  // NEW: call reporter
  Future<void> callReporter(String raw) async {
    final num = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: num);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      // Show a quick toast/snackbar if you want
    }
  }

  void addNew() {
    Get.toNamed(Routes.newSuggestionScreen);
  }
}
