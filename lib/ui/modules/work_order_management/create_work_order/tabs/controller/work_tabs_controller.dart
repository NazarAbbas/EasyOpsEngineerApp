import 'package:get/get.dart';

class WorkTabsController extends GetxController {
  final tabs = const ['Work Order Info', 'Operator Info', 'M/C History'];
  final selectedTab = 0.obs; // 0 = WorkOrderPage (default)
  void goTo(int i) => selectedTab.value = i;
}
