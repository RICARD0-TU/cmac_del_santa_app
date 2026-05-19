import '../../domain/entities/auth_session.dart';
import '../dto/auth_session_dto.dart';

extension AuthSessionMapper on AuthSessionDto {
  AuthSession toEntity() {
    return AuthSession(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
