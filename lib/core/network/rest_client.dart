// lib/network/rest_client.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:easy_ops/features/feature_login/models/login_response.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: 'https://216.48.186.237:8443/v1/api')
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // login: send Basic in header; tokens come back in response headers
  @POST('/user-login')
  Future<LoginResponse> loginBasic(@Header('Authorization') String auth);

  // raw body GET — avoid Type.fromJson problems
  @GET('/history-work-order-activity/{code}')
  Future<dynamic> getHistoryWorkOrderActivityById(@Path('code') String code);
}
