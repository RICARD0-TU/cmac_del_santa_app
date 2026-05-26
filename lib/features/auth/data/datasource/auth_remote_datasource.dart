import 'package:supabase_flutter/supabase_flutter.dart';

import '../dto/user_dto.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this.client);

  final SupabaseClient client;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    required String phone,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'dni': dni, 'phone': phone},
    );
  }

  Future<void> logout() {
    return client.auth.signOut();
  }

  Future<void> resetPassword(String email) {
    return client.auth.resetPasswordForEmail(email);
  }

  User? get currentUser => client.auth.currentUser;

  Session? get currentSession => client.auth.currentSession;

  UserDto mapUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};

    return UserDto(
      id: user.id,
      email: user.email ?? '',
      fullName: (metadata['full_name'] ?? metadata['fullName'] ?? '')
          .toString(),
      dni: (metadata['dni'] ?? '').toString(),
      phone: (metadata['phone'] ?? '').toString(),
      photoUrl: metadata['photo_url']?.toString(),
    );
  }
}
