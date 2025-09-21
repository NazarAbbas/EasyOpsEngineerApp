import 'package:get/get.dart';

class GenreralOrderDetailsTabsController extends GetxController {
  final tabs = const ['Work Order', 'Assets', 'Timeline'];
  final selectedTab = 0.obs; // 0 = WorkOrderInfoPage (default)
  void goTo(int i) => {selectedTab.value = i};
}
