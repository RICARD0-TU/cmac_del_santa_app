import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../dto/auth_session_dto.dart';

class AuthSecureStorageService {
  AuthSecureStorageService(this._storage);

  static const _sessionKey = 'auth.session';
  static const _biometricEnabledKey = 'auth.biometric_enabled';

  final FlutterSecureStorage _storage;

  Future<void> saveSession(AuthSessionDto session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<AuthSessionDto?> readSession() async {
    final rawSession = await _storage.read(key: _sessionKey);
    if (rawSession == null) {
      return null;
    }

    return AuthSessionDto.fromJson(
      jsonDecode(rawSession) as Map<String, dynamic>,
    );
  }

  Future<void> clearSession() {
    return _storage.delete(key: _sessionKey);
  }

  Future<void> setBiometricEnabled(bool value) {
    return _storage.write(key: _biometricEnabledKey, value: value.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }
}
