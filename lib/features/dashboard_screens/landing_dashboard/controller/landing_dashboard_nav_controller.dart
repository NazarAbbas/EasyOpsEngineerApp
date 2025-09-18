// lib/core/navigation/controller/landing_dashboard_nav_controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LandingRootNavController extends GetxController {
  final index = 0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: index.value);
  }

  void select(int i) {
    if (i == index.value) return;
    index.value = i;

    if (pageController.hasClients) {
      // Smooth animated page transition
      pageController.animateToPage(
        i,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic, // 👈 feels great on both iOS/Android
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.jumpToPage(i);
        }
      });
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
