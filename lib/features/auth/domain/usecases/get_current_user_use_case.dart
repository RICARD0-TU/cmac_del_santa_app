import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this.repository);

  final AuthRepository repository;

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}
