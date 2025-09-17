import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
    Color? backgroundColor, // <-- new param
    Color textColor = Colors.white,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor:
          backgroundColor ?? (isError ? Colors.redAccent : Colors.green),
      colorText: textColor,
    );
  }

  static void success(
    String message, {
    String title = 'Success',
    Color? backgroundColor,
  }) => show(
    title: title,
    message: message,
    isError: false,
    backgroundColor: backgroundColor ?? Colors.green,
  );

  static void error(
    String message, {
    String title = 'Error',
    Color? backgroundColor,
  }) => show(
    title: title,
    message: message,
    isError: true,
    backgroundColor: backgroundColor ?? Colors.redAccent,
  );
}
