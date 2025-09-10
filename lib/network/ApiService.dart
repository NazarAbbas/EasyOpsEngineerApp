// lib/network/api_service.dart
import 'package:dio/dio.dart';
import 'package:easy_ops/network/api_factory.dart';
import 'package:easy_ops/network/auth_store.dart';
import 'package:easy_ops/network/basic_auth_header.dart';
import 'package:easy_ops/network/network_exception.dart';
import 'package:easy_ops/network/rest_client.dart';
import 'package:easy_ops/ui/modules/login/models/login_response.dart';

class ApiService {
  late final RestClient _api;

  ApiService() {
    _api = createRestClient();
  }

  /// Login with Basic auth. Tokens are captured from headers by interceptor.
  Future<LoginResponse> loginWithBasic({
    required String username,
    required String password,
    bool preferRefreshForOtherApis =
        false, // change Token from here<— toggle can be set here
  }) async {
    try {
      final res = await _api.loginBasic(basicAuthHeader(username, password));
      await AuthStore.instance.setUseRefreshForAuth(preferRefreshForOtherApis);
      return res;
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getMessage(e));
    }
  }

  Future<dynamic> historyWorkOrderActivityById(String code) async {
    try {
      return await _api.getHistoryWorkOrderActivityById(code);
    } on DioException catch (e) {
      throw Exception(NetworkExceptions.getMessage(e));
    }
  }

  /// Change the token used on subsequent API calls at runtime.
  Future<void> useRefreshForOtherApis(bool value) =>
      AuthStore.instance.setUseRefreshForAuth(value);
}
