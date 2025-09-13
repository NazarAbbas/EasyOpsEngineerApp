// lib/network/api_factory.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:easy_ops/network/rest_client.dart';
import 'package:easy_ops/network/auth_header_interceptor.dart';
import 'package:easy_ops/network/token_capture_interceptor.dart';
import 'package:easy_ops/network/token_log_interceptor.dart';

RestClient createRestClient({
  String baseUrl = 'https://216.48.186.237:8443/v1/api',
  allowSelfSignedInDev = true, // set true only for dev with known cert
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(const AuthHeaderInterceptor()); // adds Authorization
  dio.interceptors.add(
    const TokenCaptureInterceptor(),
  ); // saves tokens from headers
  dio.interceptors.add(
    const TokenLogInterceptor(
      // prints req + res tokens
      enabled: true, // set false to silence
      mask: true, // set false ONLY in dev if you want full tokens
      logOnResponse: true,
    ),
  );
  dio.interceptors.add(
    LogInterceptor(
      requestHeader: true, // <— ensure headers are printed
      responseHeader: true, // <— ensure headers are printed
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  // Allow self-signed in dev (DO NOT use in prod)
  if (allowSelfSignedInDev) {
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient = () =>
        HttpClient()..badCertificateCallback = (cert, host, port) => true;
  }

  return RestClient(dio);
}
