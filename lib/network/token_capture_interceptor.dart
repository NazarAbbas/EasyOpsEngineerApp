// lib/network/token_capture_interceptor.dart
import 'package:dio/dio.dart';
import 'package:easy_ops/network/auth_store.dart';

class TokenCaptureInterceptor extends Interceptor {
  // Header names are case-insensitive; Dio handles that in Headers.value()
  final String accessHeader;
  final String refreshHeader;

  const TokenCaptureInterceptor({
    this.accessHeader = 'authorization',
    this.refreshHeader = 'refresh-token',
  });

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final headers = response.headers;

    final access = headers.value(accessHeader);
    if (access != null && access.trim().isNotEmpty) {
      await AuthStore.instance.saveAccessToken(access);
    }

    final refresh = headers.value(refreshHeader);
    if (refresh != null && refresh.trim().isNotEmpty) {
      await AuthStore.instance.saveRefreshToken(refresh);
    }

    // (Optional) also capture from body if your API ever returns it there
    final data = response.data;
    if (data is Map) {
      final bodyAccess = (data['token'] ?? data['accessToken'])?.toString();
      if (bodyAccess != null && bodyAccess.trim().isNotEmpty) {
        await AuthStore.instance.saveAccessToken(bodyAccess);
      }
      final bodyRefresh = data['refreshToken']?.toString();
      if (bodyRefresh != null && bodyRefresh.trim().isNotEmpty) {
        await AuthStore.instance.saveRefreshToken(bodyRefresh);
      }
    }

    handler.next(response);
  }
}
