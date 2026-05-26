import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../di/auth_di.dart';
import '../state/auth_state.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authNotifierProvider = authProvider;

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(bootstrap);
    return const AuthState();
  }

  Future<void> bootstrap() async {
    if (state.status != AuthStatus.checking && state.user != null) {
      return;
    }

    try {
      final user = await ref.read(getCurrentUserUseCaseProvider).call();
      final canUseBiometrics = await ref
          .read(authRepositoryProvider)
          .canUseBiometrics();

      state = state.copyWith(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: user,
        isBiometricAvailable: canUseBiometrics,
        clearError: true,
        clearSuccessMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: _readableError(error),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      final user = await ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password);

      final canUseBiometrics = await ref
          .read(authRepositoryProvider)
          .canUseBiometrics();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
        isBiometricAvailable: canUseBiometrics,
        user: user,
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: _readableError(error),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String dni,
    required String phone,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      final user = await ref
          .read(registerUseCaseProvider)
          .call(
            email: email,
            password: password,
            fullName: fullName,
            dni: dni,
            phone: phone,
          );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
        user: user,
        successMessage: 'Registro completado correctamente.',
      );
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: _readableError(error),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      await ref.read(resetPasswordUseCaseProvider).call(email);
      state = state.copyWith(
        isLoading: false,
        successMessage:
            'Te enviamos un enlace para restablecer tu clave digital.',
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: _readableError(error));
    }
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      final user = await ref.read(loginWithBiometricsUseCaseProvider).call();
      state = state.copyWith(
        status: user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        isLoading: false,
        user: user,
        error: user == null ? 'No se pudo validar la biometria.' : null,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: _readableError(error));
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await ref.read(logoutUseCaseProvider).call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccessMessage: true);
  }

  String _readableError(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
