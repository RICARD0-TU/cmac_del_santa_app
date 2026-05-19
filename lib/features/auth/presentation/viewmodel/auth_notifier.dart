import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> login({
    required String documentNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await Future<void>.delayed(const Duration(milliseconds: 350));

    state = state.copyWith(isLoading: false, isAuthenticated: true);
  }
}
