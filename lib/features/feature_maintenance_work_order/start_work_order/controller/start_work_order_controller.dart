// start_work_order_controller.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/spare_cart/models/spares_models.dart';
// ⬇️ shared cart controller (no request_spares_controller import)
import 'package:easy_ops/features/feature_maintenance_work_order/spare_cart/controller/spare_cart_controller.dart';

class StartWorkOrderController extends GetxController {
  // Demo hero values
  final subject = 'Hydraulic Leak in CNC-1'.obs;
  final priority = 'High'.obs;
  final elapsed = '00:23'.obs;
  final woCode = 'WO-2025-00123'.obs;
  final time = '10:15 AM'.obs;
  final date = '13 Sep 2025'.obs;
  final category = 'Breakdown'.obs;

  // Phone numbers (bind your real values)
  final reportedByPhone = '+911234567890'.obs;
  final maintenanceManagerPhone = '+919876543210'.obs;

  final operatorOpen = true.obs;
  final reportedBy = 'Rakesh Sharma'.obs;
  final maintenanceManager = 'Anita Verma'.obs;

  final workInfoOpen = true.obs;
  final assetLine = 'CNC-1 · Line A'.obs;
  final assetLocation = 'Bay 2 · Shop Floor'.obs;
  final description =
      'Observed hydraulic oil droplets near the spindle. Requires inspection of hoses and seals.'
          .obs;

  // Media
  final RxList<String> photoPaths = <String>[
    'https://fastly.picsum.photos/id/459/200/200.jpg?hmac=WxFjGfN8niULmp7dDQKtjraxfa4WFX-jcTtkMyH4I-Y',
    'https://fastly.picsum.photos/id/416/200/300.jpg?hmac=KIMUiPYQ0X2OQBuJIwtfL9ci1AGeu2OqrBH4GqpE7Bc',
  ].obs;
  final voiceNotePath =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'.obs;

  /// Items confirmed from the cart (after Place Order)
  final RxList<CartLine> requestedSpares = <CartLine>[].obs;

  // Track active audio players from the page
  final Set<AudioPlayer> _players = {};

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
    // ensure we stop anything if controller/page is disposed
    stopAllAudio();
    super.onClose();
  }

  // Actions
  void toggleOperator() => operatorOpen.toggle();
  void toggleWorkInfo() => workInfoOpen.toggle();

  Future<void> startOrder() async {
    await stopAllAudio(); // ⬅️ stop audio before navigating
    Get.toNamed(Routes.startWorkSubmitScreen);
  }

  /// Open Request Spares and pre-fill with already requested items
  Future<void> needSpares() async {
    await stopAllAudio(); // ⬅️ stop audio before navigating

    final cartCtrl = Get.find<SpareCartController>();
    cartCtrl.cart
      ..clear()
      ..addAll(
        requestedSpares.map(
          (l) => CartLine(
            key: l.key,
            item: l.item,
            qty: l.qty,
            cat1: l.cat1,
            cat2: l.cat2,
          ),
        ),
      );

    Get.toNamed(Routes.requestSparesScreen);
  }

  /// Merge-in lines from the cart (called by SpareCartController.placeOrder()).
  void addSparesFromCart(List<CartLine> lines) {
    for (final l in lines) {
      final idx = requestedSpares.indexWhere((e) => e.key == l.key);
      if (idx >= 0) {
        requestedSpares[idx].qty += l.qty;
      } else {
        requestedSpares.add(
          CartLine(
            key: l.key,
            item: l.item,
            qty: l.qty,
            cat1: l.cat1,
            cat2: l.cat2,
          ),
        );
      }
    }
    requestedSpares.refresh();
  }

  void openAssetHistory() async {
    await stopAllAudio(); // keep UX clean if audio is playing
    // TODO: Navigate to your history screen
    // Get.toNamed(Routes.assetHistoryScreen, arguments: {'asset': assetLine.value});
    Get.snackbar(
      'History',
      'Open asset history for ${assetLine.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
