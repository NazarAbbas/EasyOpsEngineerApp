// controller: lib/.../mc_history/controller/mc_history_controller.dart
import 'package:easy_ops/features/feature_maintenance_work_order/WorkTabsController.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/history/models/history_items.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final items = <HistoryItem>[].obs;

  @override
  void onInit() {
    // Load initial data (replace with API call if needed)
    items.assignAll(sampleHistory);
    super.onInit();
  }

  void goBack(int i) => Get.find<WorkTabsController>().goTo(i);
  //void goBack() => Get.back();
}
