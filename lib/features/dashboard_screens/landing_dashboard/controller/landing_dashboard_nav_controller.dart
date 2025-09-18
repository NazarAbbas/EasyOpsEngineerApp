// lib/core/navigation/controller/landing_dashboard_nav_controller.dart
import 'package:get/get.dart';

class LandingRootNavController extends GetxController {
  final RxInt index = 0.obs;

  void setIndex(int i) => index.value = i;
}
