import '../../domain/entities/user_entity.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.checking,
    this.isLoading = false,
    this.isBiometricAvailable = false,
    this.user,
    this.error,
    this.successMessage,
  });

  final AuthStatus status;
  final bool isLoading;
  final bool isBiometricAvailable;
  final UserEntity? user;
  final String? error;
  final String? successMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    bool? isBiometricAvailable,
    UserEntity? user,
    bool clearUser = false,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      user: clearUser ? null : user ?? this.user,
      error: clearError ? null : error,
      successMessage: clearSuccessMessage ? null : successMessage,
    );
  }
}
