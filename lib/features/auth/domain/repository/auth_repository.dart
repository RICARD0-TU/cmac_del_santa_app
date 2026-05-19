import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String documentNumber,
    required String password,
  });

  Future<void> logout();
  Future<AuthSession?> restoreSession();
}
