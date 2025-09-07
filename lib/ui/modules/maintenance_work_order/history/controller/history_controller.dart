// controller: lib/.../mc_history/controller/mc_history_controller.dart
import 'package:easy_ops/ui/modules/work_order_management/create_work_order/mc_history/models/history_items.dart';
import 'package:easy_ops/ui/modules/work_order_management/update_work_order/tabs/controller/update_work_tabs_controller.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final items = <HistoryItem>[].obs;

  @override
  void onInit() {
    // Load initial data (replace with API call if needed)
    items.assignAll(sampleHistory);
    super.onInit();
  }

  void goBack(int i) => Get.find<UpdateWorkTabsController>().goTo(i);
  //void goBack() => Get.back();
}
