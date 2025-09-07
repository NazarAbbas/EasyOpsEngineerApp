import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:flutter/material.dart';

const _kBlue = Color(0xFF2F6BFF);

class AppInput {
  static InputDecoration fieldDecoration() => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2F6BFF)),
    ),
  );

  static OutlineInputBorder _outline(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: c),
  );

  static final InputDecorationTheme theme = InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: _outline(const Color(0xFFE1E6EF)),
    enabledBorder: _outline(const Color(0xFFE1E6EF)),
    focusedBorder: _outline(_kBlue),
  );

  static InputDecoration decoration({String? hintText, Widget? suffixIcon}) =>
      InputDecoration(hintText: hintText, suffixIcon: suffixIcon);

  static const _idle = Color(0xFFE1E6EF);
  static const _focus = Color(0xFF2F6BFF);
  static InputDecoration bordered({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: _outline(_idle),
      enabledBorder: _outline(_idle),
      focusedBorder: _outline(_focus),
    );
  }

  static InputDecorationTheme get decorationTheme => InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.fieldBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.fieldBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
    ),
  );

  static InputDecoration infoPageBordered({String? hint, Widget? suffix}) =>
      InputDecoration(hintText: hint, suffixIcon: suffix);
}
