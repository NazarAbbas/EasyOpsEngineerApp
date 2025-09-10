// lib/store/auth_store.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStore {
  AuthStore._();
  static final AuthStore instance = AuthStore._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _accessToken = '';
  String _refreshToken = '';
  bool _useRefreshForAuth = false; // <— toggle

  String get accessToken => _accessToken;
  String get refreshToken => _refreshToken;
  bool get useRefreshForAuth => _useRefreshForAuth;

  Future<void> init() async {
    _accessToken = await _storage.read(key: 'auth_access_token') ?? '';
    _refreshToken = await _storage.read(key: 'auth_refresh_token') ?? '';
    _useRefreshForAuth =
        (await _storage.read(key: 'auth_use_refresh_for_auth')) == 'true';

    if (kDebugMode) {
      debugPrint(
        'AuthStore: access=${_accessToken.isNotEmpty}, refresh=${_refreshToken.isNotEmpty}, preferRefresh=$_useRefreshForAuth',
      );
    }
  }

  Future<void> saveAccessToken(String token) async {
    final t = _stripBearer(token.trim());
    _accessToken = t;
    await _storage.write(key: 'auth_access_token', value: t);
  }

  Future<void> saveRefreshToken(String token) async {
    final t = _stripBearer(token.trim());
    _refreshToken = t;
    await _storage.write(key: 'auth_refresh_token', value: t);
  }

  Future<void> setUseRefreshForAuth(bool value) async {
    _useRefreshForAuth = value;
    await _storage.write(
      key: 'auth_use_refresh_for_auth',
      value: value ? 'true' : 'false',
    );
  }

  Future<void> clear() async {
    _accessToken = '';
    _refreshToken = '';
    _useRefreshForAuth = false;
    await _storage.delete(key: 'auth_access_token');
    await _storage.delete(key: 'auth_refresh_token');
    await _storage.delete(key: 'auth_use_refresh_for_auth');
  }

  static String _stripBearer(String v) =>
      v.startsWith('Bearer ') ? v.substring(7) : v;
}
