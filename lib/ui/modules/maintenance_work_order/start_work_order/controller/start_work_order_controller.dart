import 'package:easy_ops/route_managment/routes.dart';
import 'package:get/get.dart';

/* ───────────────────────── Controller ───────────────────────── */

class StartWorkOrderController extends GetxController {
  // Header / title
  final title = 'Work Order Details'.obs;
  final tabIndex = 0.obs; // 0: Work Order, 1: Assets, 2: Timeline

  // Top summary card
  final subject = 'Conveyor Belt Stopped Abruptly During Operation'.obs;
  final woCode = 'BD-102'.obs;
  final time = '18:08'.obs;
  final date = '09 Aug'.obs;
  final category = 'Mechanical'.obs;
  final status = 'In Progress'.obs; // blue chip
  final priority = 'High'.obs; // red pill
  final elapsed = '1h 20m'.obs;

  // Operator Info (expand/collapse)
  final operatorOpen = true.obs;
  final reportedBy = 'Ashwath Mohan Mahendran'.obs;
  final reportedByPhone = '+91 90000 00001'.obs;
  final maintenanceManager = 'Rajesh Kumar'.obs;
  final maintenanceManagerPhone = '+91 90000 00002'.obs;

  // Work Order Info (expand/collapse)
  final workInfoOpen = true.obs;

  // Asset line + cost
  final assetLine = 'CNC - 1 | ₹ 2000/hr'.obs;
  final assetLocation = 'CNC Vertical Assets Center where we make housing'.obs;

  // Description
  final description =
      'Tool misalignment and spindle speed issues in Bay 3 causing uneven cuts and delays. Immediate attention needed.'
          .obs;

  // Media
  final photoPaths = <String>[
    // Fallback URLs (replace with assets later if you prefer)
    'https://fastly.picsum.photos/id/459/200/200.jpg?hmac=WxFjGfN8niULmp7dDQKtjraxfa4WFX-jcTtkMyH4I-Y',
    'https://fastly.picsum.photos/id/416/200/300.jpg?hmac=KIMUiPYQ0X2OQBuJIwtfL9ci1AGeu2OqrBH4GqpE7Bc',
  ].obs;

  // You can switch to an asset later: assets/dummy/work_orders/voice_note1.m4a
  final voiceNotePath =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'.obs;

  // Need spares?
  final needSparesOpen = false.obs;

  // Actions
  void onBack() => Get.back();
  void onOtherOptions() {}

  // ignore: non_constant_identifier_names
  void StartOrder() {
    Get.toNamed(Routes.startWorkSubmitScreen);
  }

  void toggleOperator() => operatorOpen.toggle();
  void toggleWorkInfo() => workInfoOpen.toggle();
  void toggleSpares() => needSparesOpen.toggle();
}
