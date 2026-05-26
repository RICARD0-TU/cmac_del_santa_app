import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<UserEntity> login({required String email, required String password});

  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    required String phone,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<bool> canUseBiometrics();

  Future<UserEntity?> loginWithBiometrics();
}
