import 'package:easy_ops/core/constants/constant.dart';
import 'package:easy_ops/core/theme/theme_controller.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/database/app_database.dart';
import 'package:easy_ops/database/entity/db_todo.dart';
import 'package:easy_ops/features/login/domain/repository_impl.dart';
import 'package:easy_ops/features/login/validator/validator.dart';
import 'package:easy_ops/core/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPageController extends GetxController {
  // DI: register AuthRepository in your bindings -> Get.put(AuthRepository(Get.find()));
  final RepositoryImpl repositoryImpl = RepositoryImpl();

  // Inputs
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // UI state
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final role = ''.obs;
  final themeController = Get.find<ThemeController>();

  @override
  void onInit() {
    super.onInit();
    emailController.text = "satya.eazysaas@gmail.com";
    passwordController.text = "r@Iv2Zi8iu?M";
  }

  Future<void> login() async {
    // somewhere in an async function
    final db = await AppDatabase.open();
    // insert returns the generated row id (if your @primaryKey has autoGenerate: true)
    final newId = await db.todoDao.insertOne(Todo(title: 'Nazar'));
    // read it back
    final todo = await db.todoDao.findById(newId);

    if (isLoading.value) return;

    final userName = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate
    final validationMsg = Validator.validate(userName, password);
    if (validationMsg != null) {
      AppSnackbar.error(
        validationMsg,
        duration: Duration(seconds: Constant.snackbarSmallDuration),
      );
      return;
    }

    // Dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    try {
      final result = await repositoryImpl.login(
        userName: userName,
        password: password,
      );

      debugPrint('Login HTTP code: ${result.httpCode}');

      if (result.isSuccess && result.data != null) {
        // optional: theme based on role/authorities
        // themeController.setThemeByRole('admin');

        Get.toNamed(Routes.landingDashboardScreen);
        //Get.offAll(() => const LandingDashboardTabShell());
        AppSnackbar.success(
          'Logged in successfully)',
          duration: Duration(seconds: Constant.snackbarSmallDuration),
        );
      } else {
        AppSnackbar.error(
          result.message ?? 'Login failed (HTTP ${result.httpCode})',
          duration: Duration(seconds: Constant.snackbarLongDuration),
        );
      }
    } finally {
      //isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void forgotPassword() {
    final idRaw = emailController.text.trim();
    if (idRaw.isEmpty) {
      AppSnackbar.error(
        'Please enter mobile number',
        duration: Duration(seconds: Constant.snackbarLongDuration),
      );
      return;
    }
    if (!Validator.isValidPhone(idRaw)) {
      AppSnackbar.error(
        'Please enter a valid phone number',
        duration: Duration(seconds: Constant.snackbarLongDuration),
      );
      return;
    }
    final phone = Validator.normalizePhone(idRaw);
    Get.toNamed(Routes.forgotPasswordScreen, arguments: {'phone': phone});
  }

  /* ================= Helpers ================= */

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
