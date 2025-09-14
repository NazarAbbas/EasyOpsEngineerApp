// work_order_details_controller.dart
// ignore: file_names
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ops/route_managment/routes.dart';
import 'package:get/get.dart';

class AcceptWorkOrderController extends GetxController {
  // Header
  final title = 'Work Order Details'.obs;

  // Operator
  final operatorName = 'Rajesh Kumar'.obs;
  final operatorInfo = 'Assembly | Plant A | Shift B'.obs;
  final operatorPhoneNumber = '+91 98765 43210'.obs;

  // Banner
  final successTitle = 'Work Order Created\nSuccessfully'.obs;
  final successSub = 'Work Order ID - BD-102'.obs;

  // Reporter
  final reportedBy = 'Ashwath Mohan Mahendran'.obs;

  // Summary
  final descriptionText =
      'Tool misalignment and spindle speed issues in Bay 3 causing uneven cuts and delays. Immediate attention needed.'
          .obs;
  final priority = 'High'.obs; // pill
  final issueType = 'Mechanical'.obs; // category
  final status = 'Pending'.obs; // category

  // Time / Date
  final orderId = 'BD-102'.obs; // HH:mm
  final time = '18:08'.obs; // HH:mm
  final date = '09 Aug'.obs; // dd MMM

  // Body
  final headline = 'Conveyor Belt Stopped Abruptly During Operation'.obs;
  final problemDescription =
      'Suspected bearing wear; request inspection and calibration.'.obs;

  // Media (hard-coded URLs)
  final photoPaths = <String>[
    // Fallback URLs (replace with assets later if you prefer)
    'https://fastly.picsum.photos/id/459/200/200.jpg?hmac=WxFjGfN8niULmp7dDQKtjraxfa4WFX-jcTtkMyH4I-Y',
    'https://fastly.picsum.photos/id/416/200/300.jpg?hmac=KIMUiPYQ0X2OQBuJIwtfL9ci1AGeu2OqrBH4GqpE7Bc',
    'https://fastly.picsum.photos/id/459/200/200.jpg?hmac=WxFjGfN8niULmp7dDQKtjraxfa4WFX-jcTtkMyH4I-Y',
    'https://fastly.picsum.photos/id/416/200/300.jpg?hmac=KIMUiPYQ0X2OQBuJIwtfL9ci1AGeu2OqrBH4GqpE7Bc',
  ].obs;

  final voiceNotePath =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'.obs;

  // Extra
  final cnc_1 = 'CNC-1'.obs;

  // (Optional) date formatter kept if you want to compute dates later
  String _formatDate(DateTime d) {
    const months = [
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
    final dd = d.day.toString().padLeft(2, '0');
    final mon = months[d.month - 1];
    return '$dd $mon';
  }

  // // Actions
  // void acceptWorkOrder() {

  //   Get.toNamed(Routes.startWorkOrderScreen);
  // }

  // void reAssignWorkOrder() {
  //   Get.toNamed(Routes.reassignWorkOrderScreen);
  // }

  final Set<AudioPlayer> _players = {};
  // Called by audio bubbles
  void registerPlayer(AudioPlayer p) => _players.add(p);
  void unregisterPlayer(AudioPlayer p) => _players.remove(p);

  Future<void> stopAllAudio() async {
    for (final p in _players.toList()) {
      try {
        await p.stop();
      } catch (_) {}
    }
  }

  @override
  void onClose() {
    // ensure nothing leaks if page is destroyed
    stopAllAudio();
    super.onClose();
  }

  // Your navigation actions:
  Future<void> acceptWorkOrder() async {
    await stopAllAudio();
    Get.toNamed(Routes.startWorkOrderScreen);
  }

  Future<void> reAssignWorkOrder() async {
    await stopAllAudio();
    Get.toNamed(Routes.reassignWorkOrderScreen);
  }
}
