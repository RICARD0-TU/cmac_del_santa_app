import '../entities/auth_session.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String documentNumber,
    required String password,
  }) {
    return _repository.login(
      documentNumber: documentNumber,
      password: password,
    );
  }
}
