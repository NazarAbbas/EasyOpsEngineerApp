// ignore: file_names
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class RestAPI {
  Dio dio = Get.find<Dio>();

  init() {
    BaseOptions options = BaseOptions(
      receiveDataWhenStatusError: true,
    );
    dio.options = options;
    dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
        responseBody: true,
        error: true));
    dio.options.connectTimeout = const Duration(
        days: 0,
        hours: 0,
        minutes: 1,
        seconds: 0,
        microseconds: 0,
        milliseconds: 0);
    dio.options.receiveTimeout = const Duration(
        days: 0,
        hours: 0,
        minutes: 1,
        seconds: 0,
        microseconds: 0,
        milliseconds: 0);
    dio.options.headers = {'Content-Type': 'application/json; charset=UTF-8'};
  }

  // //Get AboutUs request
  // Future<AboutUsResponse> calllAboutUsApi() async {
  //   final client = RestClient(dio);
  //   final response = await client.aboutusApi();
  //   return response;
  // }

  // //Get EPaper request
  // Future<EPaperResponse> calllEPaperApi() async {
  //   final client = RestClient(dio);
  //   final response = await client.ePaperApi();
  //   return response;
  // }

  // //Get News request
  // Future<NewsListResponse> callNewsListApi(
  //     {required String categoryId,
  //     required String locationId,
  //     required int pageSize,
  //     required int pageNumber,
  //     required int languageId,
  //     required int newsTypeId,
  //     required String searchText}) async {
  //   final client = RestClient(dio);
  //   final response = await client.newsListApi(categoryId, locationId,
  //       languageId, pageSize, pageNumber, newsTypeId, searchText);
  //   return response;
  // }

  // // News Locations request
  // Future<LocationsResponse> calllNewsLocations() async {
  //   final client = RestClient(dio);
  //   final response = await client.newsLocationsApi();
  //   return response;
  // }

  // // Advertisement request
  // Future<AdvertisementResponse> calllAdvertisement() async {
  //   final client = RestClient(dio);
  //   final response = await client.advertisementsApi();
  //   return response;
  // }

  // // News Categories request
  // Future<CategoriesResponse> calllNewsCategories() async {
  //   final client = RestClient(dio);
  //   final response = await client.newsCategoryApi();
  //   return response;
  // }
}