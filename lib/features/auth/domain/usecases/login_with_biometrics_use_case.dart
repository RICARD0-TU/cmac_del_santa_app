import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

class LoginWithBiometricsUseCase {
  const LoginWithBiometricsUseCase(this.repository);

  final AuthRepository repository;

  Future<UserEntity?> call() {
    return repository.loginWithBiometrics();
  }
}
