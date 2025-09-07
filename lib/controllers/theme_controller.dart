import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static const _fontFamily = 'Inter';

  ThemeData _exactTheme(Color primary, {Color? secondary}) {
    // Build a precise, non-seeded ColorScheme
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary ?? primary,
      onSecondary: Colors.white,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF111827),
      background: Colors.white,
      onBackground: const Color(0xFF111827),
    );

    return ThemeData(
      fontFamily: _fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary, // <- EXACT primary
        foregroundColor: scheme.onPrimary,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        titleTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
    );
  }

  // Map roles -> precise themes
  late final ThemeData userTheme = _exactTheme(const Color(0xFF2F6BFF));
  late final ThemeData adminTheme = _exactTheme(AppColors.darkGray);
  late final ThemeData sellerTheme = _exactTheme(Colors.teal);
  late final ThemeData superUserTheme = _exactTheme(Colors.deepPurple);
  late final ThemeData auditorTheme = _exactTheme(Colors.indigo);
  late final ThemeData guestTheme = _exactTheme(Colors.grey);

  late final Map<String, ThemeData> _byRole = {
    'user': userTheme,
    'admin': adminTheme,
    'seller': sellerTheme,
    'superuser': superUserTheme,
    'super user': superUserTheme,
    'auditor': auditorTheme,
    'guest': guestTheme,
  };

  final Rx<ThemeData> currentTheme = ThemeData().obs;

  @override
  void onInit() {
    super.onInit();
    currentTheme.value = userTheme;
  }

  void setThemeByRole(String role) {
    final key = role.trim().toLowerCase();
    final t = _byRole[key] ?? userTheme;
    currentTheme.value = t; // rebuilds GetMaterialApp(theme: ...)
    Get.changeTheme(t); // also update Get’s theme context-wide
  }
}
