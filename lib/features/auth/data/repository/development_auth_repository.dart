import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../dto/auth_session_dto.dart';
import '../services/auth_secure_storage_service.dart';
import '../services/biometric_auth_service.dart';

class DevelopmentAuthRepository implements AuthRepository {
  DevelopmentAuthRepository({
    required AuthSecureStorageService secureStorage,
    required BiometricAuthService biometricAuthService,
  }) : _secureStorage = secureStorage,
       _biometricAuthService = biometricAuthService;

  static const _demoUser = UserEntity(
    id: 'dev-user-cmac-del-santa',
    email: 'demo@cmacdelsanta.pe',
    fullName: 'Cliente Demo',
    dni: '00000000',
    phone: '999999999',
  );

  final AuthSecureStorageService _secureStorage;
  final BiometricAuthService _biometricAuthService;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.length < 6) {
      throw Exception('Ingresa un correo valido y una clave de 6 caracteres.');
    }

    await _saveDemoSession(email.trim());
    return UserEntity(
      id: _demoUser.id,
      email: email.trim(),
      fullName: _demoUser.fullName,
      dni: _demoUser.dni,
      phone: _demoUser.phone,
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    required String phone,
  }) async {
    await _saveDemoSession(email.trim());
    return UserEntity(
      id: _demoUser.id,
      email: email.trim(),
      fullName: fullName.trim(),
      dni: dni.trim(),
      phone: phone.trim(),
    );
  }

  @override
  Future<void> logout() {
    return _secureStorage.clearSession();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final session = await _secureStorage.readSession();
    if (session == null) {
      return null;
    }

    return _demoUser;
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<bool> canUseBiometrics() async {
    final hasSavedSession = await _secureStorage.readSession() != null;
    final canAuthenticate = await _biometricAuthService.canAuthenticate();
    return hasSavedSession && canAuthenticate;
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

  Future<void> _saveDemoSession(String email) async {
    await _secureStorage.saveSession(
      AuthSessionDto(
        userId: _demoUser.id,
        accessToken: 'development-access-token-$email',
        refreshToken: 'development-refresh-token',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    await _secureStorage.setBiometricEnabled(true);
  }
}
