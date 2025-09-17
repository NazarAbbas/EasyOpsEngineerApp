import 'package:dio/dio.dart';
import 'package:easy_ops/core/network/ApiService.dart';
import 'package:easy_ops/core/network/api_result.dart';
import 'package:easy_ops/core/network/network_exception.dart';
import 'package:easy_ops/features/login/domain/repository.dart';
import 'package:easy_ops/features/login/models/login_response.dart';
import 'package:get/get.dart';

class RepositoryImpl implements Repository {
  final ApiService _apiService = Get.find<ApiService>();

  @override
  Future<ApiResult<LoginResponse>> login({
    required String userName,
    required String password,
  }) async {
    try {
      final model = await _apiService.loginWithBasic(
        username: userName,
        password: password,
      );
      return ApiResult<LoginResponse>(
        httpCode: 200,
        data: model,
        message: model.message,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      final msg = NetworkExceptions.getMessage(e);
      return ApiResult<LoginResponse>(httpCode: code, data: null, message: msg);
    } catch (e) {
      return ApiResult<LoginResponse>(
        httpCode: 0,
        data: null,
        message: e.toString(),
      );
    }
  }
}
