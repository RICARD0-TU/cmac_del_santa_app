import '../dto/auth_session_dto.dart';

abstract interface class AuthRemoteDatasource {
  Future<AuthSessionDto> login({
    required String documentNumber,
    required String password,
  });
}
