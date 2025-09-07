import 'dart:io';


import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;


//part 'rest_client.g.dart';

class Apis {
  static const String aboutUs = '/Gandiv/aboutus';
  static const String ePaper = '/Gandiv/epaper';
  static const String newsList = '/news';
  static const String newsCategories = '/news/categories';
  static const String newsLocations = '/news/locations';
  static const String advertisements = '/advertisements';
}

@RestApi(baseUrl: "https://api.gandivsamachar.com/api")
abstract class RestClient {
//  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // @GET(Apis.aboutUs)
  // Future<AboutUsResponse> aboutusApi();

  // @GET(Apis.ePaper)
  // Future<EPaperResponse> ePaperApi();

  // @GET(Apis.newsCategories)
  // Future<CategoriesResponse> newsCategoryApi();

  // @GET(Apis.newsLocations)
  // Future<LocationsResponse> newsLocationsApi();

  // @GET(Apis.advertisements)
  // Future<AdvertisementResponse> advertisementsApi();

  // @GET(Apis.newsList)
  // Future<NewsListResponse> newsListApi(
  //     [@Query("CategoryId") String? categoryId,
  //     @Query("LocationId") String? locationId,
  //     @Query("LanguageId") int? laguageId,
  //     @Query("PageSize") int? pageSize,
  //     @Query("PageNumber") int? pageNumber,
  //     @Query("NewsTypeId") int? newsTypeId,
  //     @Query("SearchText") String? searchText]);
}