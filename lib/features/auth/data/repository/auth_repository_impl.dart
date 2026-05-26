import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../dto/auth_session_dto.dart';
import '../mapper/user_mapper.dart';
import '../services/auth_secure_storage_service.dart';
import '../services/biometric_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDatasource datasource,
    required AuthSecureStorageService secureStorage,
    required BiometricAuthService biometricAuthService,
  }) : _datasource = datasource,
       _secureStorage = secureStorage,
       _biometricAuthService = biometricAuthService;

  final AuthRemoteDatasource _datasource;
  final AuthSecureStorageService _secureStorage;
  final BiometricAuthService _biometricAuthService;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _datasource.login(
        email: email.trim(),
        password: password,
      );

      return _handleAuthenticatedResponse(response);
    } on AuthException catch (error, stackTrace) {
      throw AppException(
        _mapAuthError(error.message),
        code: error.statusCode,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    required String phone,
  }) async {
    try {
      final response = await _datasource.register(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        dni: dni.trim(),
        phone: phone.trim(),
      );

      return _handleAuthenticatedResponse(response);
    } on AuthException catch (error, stackTrace) {
      throw AppException(
        _mapAuthError(error.message),
        code: error.statusCode,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _datasource.logout();
    await _secureStorage.clearSession();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _datasource.currentUser;
    final session = _datasource.currentSession;

    if (user == null || session == null) {
      await _secureStorage.clearSession();
      return null;
    }

    await _persistSession(user.id, session);
    return _datasource.mapUser(user).toEntity();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _datasource.resetPassword(email.trim());
    } on AuthException catch (error, stackTrace) {
      throw AppException(
        _mapAuthError(error.message),
        code: error.statusCode,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> canUseBiometrics() async {
    final hasSavedSession = await _secureStorage.readSession() != null;
    final isEnabled = await _secureStorage.isBiometricEnabled();
    final canAuthenticate = await _biometricAuthService.canAuthenticate();
    return hasSavedSession && isEnabled && canAuthenticate;
  }

  @override
  Future<UserEntity?> loginWithBiometrics() async {
    final canAuthenticate = await canUseBiometrics();
    if (!canAuthenticate) {
      return null;
    }

    final authenticated = await _biometricAuthService.authenticateForLogin();
    if (!authenticated) {
      return null;
    }

    return getCurrentUser();
  }

  Future<UserEntity> _handleAuthenticatedResponse(AuthResponse response) async {
    final user = response.user;
    final session = response.session;

    if (user == null) {
      throw const AppException('Usuario no encontrado.');
    }

    if (session != null) {
      await _persistSession(user.id, session);
      await _secureStorage.setBiometricEnabled(true);
    }

    return _datasource.mapUser(user).toEntity();
  }

  Future<void> _persistSession(String userId, Session session) {
    return _secureStorage.saveSession(
      AuthSessionDto(
        userId: userId,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        expiresAt: session.expiresAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
      ),
    );
  }

  String _mapAuthError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('invalid login') ||
        normalized.contains('invalid credentials')) {
      return 'Correo o clave digital incorrectos.';
    }
    if (normalized.contains('email not confirmed')) {
      return 'Confirma tu correo antes de ingresar.';
    }
    if (normalized.contains('network')) {
      return 'No se pudo conectar. Revisa tu conexion e intenta nuevamente.';
    }

    return message;
  }
}
