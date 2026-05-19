import 'package:supabase_flutter/supabase_flutter.dart';

import '../dto/auth_session_dto.dart';
import 'auth_remote_datasource.dart';

class SupabaseAuthDatasource implements AuthRemoteDatasource {
  SupabaseAuthDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthSessionDto> login({
    required String documentNumber,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: documentNumber,
      password: password,
    );

    final session = response.session;
    final user = response.user;

    if (session == null || user == null) {
      throw const AuthException('No se pudo iniciar sesion.');
    }

    return AuthSessionDto(
      userId: user.id,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
    );
  }
}
