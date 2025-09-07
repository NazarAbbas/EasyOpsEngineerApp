
import 'dart:async' show Timer;
import 'package:easy_ops/route_managment/routes.dart';
import 'package:get/get.dart';


class SplashPageController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
     Timer(const Duration(seconds: 3),
           () => Get.offNamed(Routes.loginScreen));
  }
}
