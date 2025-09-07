import 'package:dio/dio.dart';
import 'package:easy_ops/network/rest_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DependencyInjection {
  static init() async {
    Get.put<Dio>(Dio()); //initializing Dio
    Get.put<RestAPI>(RestAPI()); //initializing REST API class

    WidgetsFlutterBinding.ensureInitialized();

    // await Get.putAsync<AppDatabase>(permanent: true, () async {
    //   final db = await $FloorAppDatabase
    //       .databaseBuilder(Constant.databaseName)
    //       .build();
    //   return db;
    // });
  }
}
