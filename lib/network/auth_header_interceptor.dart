// lib/network/auth_header_interceptor.dart
import 'package:dio/dio.dart';
import 'package:easy_ops/network/auth_store.dart';

class AuthHeaderInterceptor extends Interceptor {
  final String headerKey; // usually "Authorization"
  final String scheme; // usually "Bearer"
  final bool respectExisting; // don't overwrite if caller set Authorization

  const AuthHeaderInterceptor({
    this.headerKey = 'Authorization',
    this.scheme = 'Bearer',
    this.respectExisting = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // keep Basic header for login or any explicit Authorization from caller
    if (respectExisting && _hasHeader(options.headers, headerKey)) {
      return handler.next(options);
    }

    final store = AuthStore.instance;
    // choose token by toggle (fallback to access if refresh is empty)
    final chosen = store.useRefreshForAuth
        ? (store.refreshToken.isNotEmpty
              ? store.refreshToken
              : store.accessToken)
        : store.accessToken;

    if (chosen.isNotEmpty) {
      final value =
          (chosen.startsWith('$scheme ') || chosen.startsWith('Basic '))
          ? chosen
          : '$scheme $chosen';
      options.headers[headerKey] = value;
    }

    options.headers['Content-Type'] ??= 'application/json';
    handler.next(options);
  }

  bool _hasHeader(Map<String, dynamic> headers, String key) =>
      headers.containsKey(key) || headers.containsKey(key.toLowerCase());
}
