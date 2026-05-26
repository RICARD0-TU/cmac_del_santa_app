import '../repository/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call(String email) {
    return repository.resetPassword(email);
  }
}
