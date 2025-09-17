import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ops/core/constants/constant.dart';
import 'package:easy_ops/core/injector/app_injector.dart';
import 'package:easy_ops/core/constants/app_strings.dart';
import 'package:easy_ops/core/network/auth_store.dart';
import 'package:easy_ops/core/route_management/all_pages.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/core/binding/screen_binding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AudioPlayer.global.setAudioContext(
    const AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: [AVAudioSessionOptions.mixWithOthers],
      ),
    ),
  );
  await AppInjector.init();
  await GetStorage.init();
  // HttpOverrides.global = MyHttpOverrides();
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );

  final themeCtrl = Get.put(ThemeController(), permanent: true);
  // Example: set role once you know it (e.g., after login/api)
  const userRoleFromApi = 'admin';
  themeCtrl.setThemeByRole(userRoleFromApi);
  await AuthStore.instance.init(); // restores token into memory
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final String language = Constant.englishLanguage;
    final String country = Constant.englishCountry;

    // Compose EasyLoading + global AnnotatedRegion in ONE builder
    final TransitionBuilder easyLoadingBuilder = EasyLoading.init();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: AppStrings(),
        locale: Locale(language, country),
        fallbackLocale: Locale(language, country),
        theme: themeController.currentTheme.value,
        initialRoute: Routes.splashScreen,
        initialBinding: ScreenBindings(),
        getPages: AllPages.getPages(),

        // Single builder: EasyLoading wrapped by AnnotatedRegion (white status bar icons)
        builder: (context, child) {
          final easyWrapped = easyLoadingBuilder(context, child);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light, // ANDROID → white
              statusBarBrightness: Brightness.dark, // iOS    → white
            ),
            child: easyWrapped,
          );
        },
      );
    });
  }
}
