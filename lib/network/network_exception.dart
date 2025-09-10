import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkExceptions {
  /// Convert any error into a user-friendly message.
  static String getMessage(dynamic error) {
    try {
      // Direct network issues (outside Dio)
      if (error is TimeoutException) return "Request timed out";
      if (error is SocketException) return _socketMessage(error);
      if (error is HandshakeException || error is TlsException) {
        return "Secure connection failed";
      }
      if (error is HttpException) return "HTTP connection error";
      if (error is FormatException) return "Invalid response format";

      // Dio-specific
      if (error is DioException) {
        final res = error.response;
        final code = res?.statusCode;
        final serverMsg = _extractServerMessage(res);

        switch (error.type) {
          case DioExceptionType.cancel:
            return "Request cancelled";

          case DioExceptionType.connectionTimeout:
            return "Connection timeout";

          case DioExceptionType.sendTimeout:
            return "Send timeout while connecting to server";

          case DioExceptionType.receiveTimeout:
            return "Receive timeout while waiting for server response";

          case DioExceptionType.badCertificate:
            return "Bad SSL certificate";

          case DioExceptionType.connectionError:
            // Often offline, DNS, or connection reset
            final u = error.error;
            if (u is SocketException) return _socketMessage(u);
            if (u is HandshakeException || u is TlsException) {
              return "Secure connection failed";
            }
            if (_looksLikeDnsFailure(error.message ?? "")) {
              return "Unable to resolve server address";
            }
            return serverMsg ?? "Connection error";

          case DioExceptionType.badResponse:
            // Prefer server message if present & safe
            if (serverMsg != null && serverMsg.trim().isNotEmpty) {
              return serverMsg;
            }
            // Map common status codes
            return _statusText(code);

          case DioExceptionType.unknown:
            // Inspect underlying error for hints
            final u = error.error;
            if (u is SocketException) return _socketMessage(u);
            if (u is TimeoutException) return "Request timed out";
            if (u is HandshakeException || u is TlsException) {
              return "Secure connection failed";
            }
            if (u is FormatException) return "Invalid response format";
            if (_looksLikeDnsFailure("${error.message}${u ?? ''}")) {
              return "Unable to resolve server address";
            }
            return serverMsg ?? "Unexpected error";
        }
      }

      // Other Dart/runtime errors
      if (error is TypeError || error is StateError) {
        return "Unexpected data format";
      }

      // Fallbacks
      final s = error?.toString() ?? '';
      if (s.contains("is not a subtype of")) {
        return "Unable to process the data";
      }
      if (s.toLowerCase().contains("broken pipe")) {
        return "Connection was interrupted";
      }
      return "Unexpected error";
    } catch (e, st) {
      if (kDebugMode) {
        // Keep logs only in debug; never show raw errors to users.
        // ignore: avoid_print
        print("NetworkExceptions fallback: $e\n$st");
      }
      return "Unexpected error";
    }
  }

  /// Try to read a meaningful message from the server response body.
  /// Supports common shapes: {message}, {error}, {detail}, {title},
  /// {errors:[{message}]}, plain String (non-HTML).
  static String? _extractServerMessage(Response? res) {
    if (res == null) return null;

    // Occasionally APIs encode text in bytes; Dio decodes for JSON,
    // but if it's still raw String, guard against HTML pages.
    final data = res.data;

    if (data is String) {
      final t = data.trim();
      if (t.isEmpty) return null;
      if (_looksLikeHtml(t)) return null;
      return t;
    }

    if (data is Map) {
      // Common single-field locations
      for (final k in const ['message', 'error', 'detail', 'title', 'msg']) {
        final v = data[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      // errors: [{message: ...}] or errors: ["..."]
      final errs = data['errors'];
      if (errs is List && errs.isNotEmpty) {
        final first = errs.first;
        if (first is String && first.trim().isNotEmpty) return first.trim();
        if (first is Map) {
          final m = first['message'] ?? first['detail'] ?? first['error'];
          if (m is String && m.trim().isNotEmpty) return m.trim();
        }
      }
      // data: { data: {...}, message: "..."} → already checked "message"
    }

    // Some APIs return arrays of strings
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
      if (first is Map) {
        for (final k in const ['message', 'error', 'detail', 'title']) {
          final v = first[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    }

    return null;
  }

  /// Map HTTP status code to a generic message.
  static String _statusText(int? code) {
    switch (code) {
      // 2xx should not normally hit badResponse, but handle just in case
      case 204:
        return "No content received";
      // Client errors
      case 400:
        return "Bad request";
      case 401:
        return "Unauthorized";
      case 402:
        return "Payment required";
      case 403:
        return "Forbidden";
      case 404:
        return "Not found";
      case 405:
        return "Method not allowed";
      case 406:
        return "Not acceptable";
      case 408:
        return "Request timeout";
      case 409:
        return "Conflict";
      case 410:
        return "Resource is gone";
      case 411:
        return "Length required";
      case 412:
        return "Precondition failed";
      case 413:
        return "Payload too large";
      case 414:
        return "URI too long";
      case 415:
        return "Unsupported media type";
      case 416:
        return "Range not satisfiable";
      case 417:
        return "Expectation failed";
      case 418:
        return "I’m a teapot";
      case 421:
        return "Misdirected request";
      case 422:
        return "Unprocessable entity";
      case 423:
        return "Locked";
      case 424:
        return "Failed dependency";
      case 426:
        return "Upgrade required";
      case 428:
        return "Precondition required";
      case 429:
        return "Too many requests";
      case 431:
        return "Request header fields too large";
      case 451:
        return "Unavailable for legal reasons";
      // Server errors
      case 500:
        return "Internal server error";
      case 501:
        return "Not implemented";
      case 502:
        return "Bad gateway";
      case 503:
        return "Service unavailable";
      case 504:
        return "Gateway timeout";
      case 505:
        return "HTTP version not supported";
      case 507:
        return "Insufficient storage";
      case 511:
        return "Network authentication required";
      default:
        return "HTTP error${code != null ? ' ($code)' : ''}";
    }
  }

  /// More helpful text for common SocketException patterns.
  static String _socketMessage(SocketException e) {
    final msg = (e.osError?.message ?? e.message).toLowerCase();
    if (_looksLikeDnsFailure(msg)) return "Unable to resolve server address";
    if (msg.contains("connection refused")) {
      return "Server refused the connection";
    }
    if (msg.contains("timed out") || msg.contains("timeout")) {
      return "Connection timeout";
    }
    if (msg.contains("network is unreachable")) return "Network is unreachable";
    if (msg.contains("software caused connection abort")) {
      return "Connection was aborted";
    }
    return "No internet connection";
  }

  static bool _looksLikeDnsFailure(String s) {
    final t = s.toLowerCase();
    return t.contains("failed host lookup") ||
        t.contains("host lookup failed") ||
        t.contains("dns") ||
        t.contains("name or service not known");
  }

  static bool _looksLikeHtml(String s) {
    final t = s.trimLeft();
    return t.startsWith('<!doctype html') ||
        t.startsWith('<html') ||
        t.contains("<head>") && t.contains("</head>");
  }
}
