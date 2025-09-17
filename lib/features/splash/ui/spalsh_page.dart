// ignore_for_file: library_private_types_in_public_api

import 'package:easy_ops/core/theme/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ops/features/splash/controller/splash_controller.dart';

class SplashPage extends StatelessWidget {
  SplashPage({super.key});
  final SplashPageController controller = Get.put(SplashPageController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600; // breakpoint for tablet

    final iconSize = isTablet ? size.width * 0.1 : size.width * 0.15;
    final fontSize = isTablet ? size.width * 0.08 : size.width * 0.12;
    final spacing = isTablet ? 16.0 : 8.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.gearIcon,
                width: iconSize,
                height: iconSize,
                color: Colors.white,
              ),
              SizedBox(width: spacing),
              Text(
                "EasyOps",
                style: TextStyle(
                  fontFamily: 'inter',
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
