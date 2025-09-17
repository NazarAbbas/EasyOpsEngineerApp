// lib/network/basic_auth_header.dart
import 'dart:convert';

String basicAuthHeader(String username, String password) {
  final raw = '$username:$password';
  final b64 = base64Encode(utf8.encode(raw));
  return 'Basic $b64';
}
