import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

enum DocType { pdf, video }

class SupportDoc {
  final String title;
  final int pages;
  final DocType type;
  final String? url; // http(s) to open
  const SupportDoc({
    required this.title,
    required this.pages,
    required this.type,
    this.url,
  });
}

class SupportController extends GetxController {
  // Static / fetched device info
  final softwareVersion = '1.0.39'.obs;
  final deviceModel = 'Samsung A22 5G (2021)'.obs;
  final osVersion = 'Android 14.0.6'.obs;

  // Dynamic state
  final lastSync = DateTime(2024, 11, 24, 16, 7).obs;
  final connectivity = 'Online'.obs;

  // Contact
  final supportEmail = 'support@easy-ops.example';
  final supportPhone = '+91 9876543210';

  // Support materials
  final docs = <SupportDoc>[
    SupportDoc(
      title: 'How to create Breakdown Work Order',
      pages: 122,
      type: DocType.pdf,
      url: 'https://www.africau.edu/images/default/sample.pdf',
    ),
    SupportDoc(
      title: 'Safety & Privacy',
      pages: 22,
      type: DocType.pdf,
      url:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    ),
    SupportDoc(
      title: 'How to return unused inventory',
      pages: 22,
      type: DocType.video,
      url: 'https://youtu.be/dQw4w9WgXcQ', // sample
    ),
  ].obs;

  // ===== Actions =====
  Future<void> refreshSoftware() async {
    // simulate fetch
    await Future.delayed(const Duration(milliseconds: 600));
    // keep same version; show snackbar
    Get.snackbar('Up to date', 'Latest version is installed');
  }

  Future<void> refreshSync() async {
    await Future.delayed(const Duration(milliseconds: 300));
    lastSync.value = DateTime.now();
  }

  Future<void> sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Support query from Easy Ops',
        'body': 'Hi Support Team,%0D%0A%0D%0A(Describe your issue here.)',
      },
    );
    await _launch(uri, 'email app');
  }

  Future<void> callSupport() async {
    final sanitized = supportPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: sanitized);
    await _launch(uri, 'dialer');
  }

  Future<void> openDoc(SupportDoc d) async {
    if (d.url == null || d.url!.isEmpty) {
      Get.snackbar('Unavailable', 'No link provided for this item');
      return;
    }
    final uri = Uri.parse(d.url!);
    await _launch(uri, 'browser');
  }

  Future<void> _launch(Uri uri, String appName) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) Get.snackbar('Couldn\'t open $appName', uri.toString());
  }
}
