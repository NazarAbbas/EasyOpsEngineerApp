import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void show({
    required String title,
    required String message,
    required Duration duration, // <-- always required
    bool isError = false,
    Color? backgroundColor,
    Color textColor = Colors.white,
    SnackPosition position = SnackPosition.TOP,
    bool isDismissible = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor:
          backgroundColor ?? (isError ? Colors.redAccent : Colors.green),
      colorText: textColor,
      duration: duration, // <-- must pass
      isDismissible: isDismissible,
    );
  }

  static void success(
    String message, {
    required Duration duration, // <-- always required
    String title = 'Success',
    Color? backgroundColor,
  }) => show(
    title: title,
    message: message,
    duration: duration,
    isError: false,
    backgroundColor: backgroundColor ?? Colors.green,
  );

  static void error(
    String message, {
    required Duration duration, // <-- always required
    String title = 'Error',
    Color? backgroundColor,
  }) => show(
    title: title,
    message: message,
    duration: duration,
    isError: true,
    backgroundColor: backgroundColor ?? Colors.redAccent,
  );
}
