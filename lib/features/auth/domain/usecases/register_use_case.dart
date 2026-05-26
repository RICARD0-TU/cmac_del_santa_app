import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this.repository);

  final AuthRepository repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    required String phone,
  }) {
    return repository.register(
      email: email,
      password: password,
      fullName: fullName,
      dni: dni,
      phone: phone,
    );
  }
}
