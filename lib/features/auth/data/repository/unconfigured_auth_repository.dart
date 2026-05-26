import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';

class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  static const _message =
      'Supabase no esta configurado. Ejecuta flutter run con SUPABASE_URL y SUPABASE_ANON_KEY.';

  @override
  Future<UserEntity> login({required String email, required String password}) {
    throw const AppException(_message, code: 'supabase_not_configured');
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    required String phone,
  }) {
    throw const AppException(_message, code: 'supabase_not_configured');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<void> resetPassword(String email) {
    throw const AppException(_message, code: 'supabase_not_configured');
  }

  @override
  Future<bool> canUseBiometrics() async => false;

  @override
  Future<UserEntity?> loginWithBiometrics() async => null;
}
