import 'package:get/get.dart';

class WorkTabsController extends GetxController {
  final tabs = const ['Work Order', 'History', 'Timeline'];
  final selectedTab = 0.obs; // 0 = WorkOrderInfoPage (default)
  void goTo(int i) => {selectedTab.value = i};
}
