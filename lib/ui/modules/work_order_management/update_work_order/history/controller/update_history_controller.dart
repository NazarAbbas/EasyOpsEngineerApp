// controller: lib/.../mc_history/controller/mc_history_controller.dart
import 'package:easy_ops/ui/modules/work_order_management/update_work_order/history/models/update_history_items.dart';
import 'package:easy_ops/ui/modules/work_order_management/update_work_order/tabs/controller/update_work_tabs_controller.dart';
import 'package:get/get.dart';

class UpdateHistoryController extends GetxController {
  final items = <UpdateHistoryItem>[].obs;

  @override
  void onInit() {
    // Load initial data (replace with API call if needed)
    items.assignAll(updateSampleHistory);
    super.onInit();
  }

  void goBack(int i) => Get.find<UpdateWorkTabsController>().goTo(i);
  //void goBack() => Get.back();
}
