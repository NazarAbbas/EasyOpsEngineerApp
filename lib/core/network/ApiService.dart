// lib/network/api_service.dart
import 'package:easy_ops/core/network/api_factory.dart';
import 'package:easy_ops/core/network/auth_store.dart';
import 'package:easy_ops/core/network/basic_auth_header.dart';
import 'package:easy_ops/core/network/rest_client.dart';
import 'package:easy_ops/features/login/models/login_response.dart';

class ApiService {
  late final RestClient _api;

  ApiService() {
    _api = createRestClient();
  }

  /// Throws on failure (e.g., DioException). Returns parsed model on success.
  Future<LoginResponse> loginWithBasic({
    required String username,
    required String password,
    bool preferRefreshForOtherApis = false,
  }) async {
    final model = await _api.loginBasic(basicAuthHeader(username, password));
    await AuthStore.instance.setUseRefreshForAuth(preferRefreshForOtherApis);
    return model; // success path only
  }

  /// Example: throws on failure, returns parsed data on success
  Future<dynamic> historyWorkOrderActivityById(String code) async {
    return _api.getHistoryWorkOrderActivityById(code);
  }

  Future<void> useRefreshForOtherApis(bool value) =>
      AuthStore.instance.setUseRefreshForAuth(value);
}
