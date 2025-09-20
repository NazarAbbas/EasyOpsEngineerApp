import 'package:get/get.dart';

class PreventiveRootNavController extends GetxController {
  final RxInt index = 0.obs;

  void setIndex(int i) => index.value = i;
}

// class PreventiveRootNavController extends GetxController {
//   final index = 3.obs; // starts on Work Orders
//   late final PageController pageController;

//   @override
//   void onInit() {
//     super.onInit();
//     pageController = PageController(initialPage: index.value);
//   }

//   void select(int i) {
//     if (i == index.value) return;
//     index.value = i;

//     if (pageController.hasClients) {
//       pageController.animateToPage(
//         i,
//         duration: const Duration(milliseconds: 320),
//         curve: Curves.easeOutCubic,
//       );
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (pageController.hasClients) {
//           pageController.jumpToPage(i); // first attach, no animation needed
//         }
//       });
//     }
//   }

//   @override
//   void onClose() {
//     pageController.dispose();
//     super.onClose();
//   }
// }
