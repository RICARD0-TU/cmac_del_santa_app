import '../../domain/entities/auth_session.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../mapper/auth_session_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDatasource);

  final AuthRemoteDatasource _remoteDatasource;

  @override
  Future<AuthSession> login({
    required String documentNumber,
    required String password,
  }) async {
    final dto = await _remoteDatasource.login(
      documentNumber: documentNumber,
      password: password,
    );
    return dto.toEntity();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthSession?> restoreSession() async {
    return null;
  }
}
