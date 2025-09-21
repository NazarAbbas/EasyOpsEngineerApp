import 'package:easy_ops/core/network/api_result.dart';
import 'package:easy_ops/features/feature_login/models/login_response.dart';

abstract class Repository {
  Future<ApiResult<LoginResponse>> login({
    required String userName,
    required String password,
  });
}
