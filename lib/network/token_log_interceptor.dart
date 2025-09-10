// lib/network/token_log_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TokenLogInterceptor extends Interceptor {
  final bool enabled;
  final bool mask;
  final bool logOnResponse;

  const TokenLogInterceptor({
    this.enabled = kDebugMode, // won’t log in release by default
    this.mask = true,
    this.logOnResponse = true, // print tokens from response headers
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      final auth =
          (options.headers['Authorization'] ?? options.headers['authorization'])
              ?.toString();
      final out = (auth == null || auth.isEmpty)
          ? '<no Authorization header>'
          : (mask ? _maskAuth(auth) : auth);
      debugPrint('[AUTH][REQ] ${options.method} ${options.uri} -> $out');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enabled && logOnResponse) {
      final access = response.headers.value('authorization');
      final refresh = response.headers.value('refresh-token');

      if (access != null && access.isNotEmpty) {
        final printable = mask ? _maskAuth('Bearer $access') : 'Bearer $access';
        debugPrint('[AUTH][RES] ${response.requestOptions.uri} -> $printable');
      }
      if (refresh != null && refresh.isNotEmpty) {
        final printable = mask ? _maskToken(refresh) : refresh;
        debugPrint(
          '[REFRESH][RES] ${response.requestOptions.uri} -> $printable',
        );
      }
    }
    super.onResponse(response, handler);
  }

  String _maskAuth(String v) {
    if (v.startsWith('Bearer ')) {
      final t = v.substring(7);
      return 'Bearer ${_maskToken(t)}';
    }
    if (v.startsWith('Basic ')) return 'Basic <redacted>';
    return '<redacted>';
  }

  String _maskToken(String t) => t.length <= 10
      ? '${t.substring(0, 2)}•••${t.substring(t.length - 2)}'
      : '${t.substring(0, 6)}…${t.substring(t.length - 6)}';
}
