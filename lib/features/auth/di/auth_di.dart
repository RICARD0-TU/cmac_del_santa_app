import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/di/app_providers.dart';
import '../../../app/config/app_environment.dart';
import '../data/datasource/auth_remote_datasource.dart';
import '../data/repository/auth_repository_impl.dart';
import '../data/repository/development_auth_repository.dart';
import '../data/repository/unconfigured_auth_repository.dart';
import '../data/services/auth_secure_storage_service.dart';
import '../data/services/biometric_auth_service.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/usecases/get_current_user_use_case.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/login_with_biometrics_use_case.dart';
import '../domain/usecases/logout_use_case.dart';
import '../domain/usecases/register_use_case.dart';
import '../domain/usecases/reset_password_use_case.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authSecureStorageProvider = Provider<AuthSecureStorageService>((ref) {
  return AuthSecureStorageService(ref.watch(flutterSecureStorageProvider));
});

final localAuthenticationProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return LocalBiometricAuthService(ref.watch(localAuthenticationProvider));
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource?>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (!environment.hasSupabaseConfig) {
    return null;
  }

  return AuthRemoteDatasource(Supabase.instance.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authRemoteDatasourceProvider);
  final environment = ref.watch(appEnvironmentProvider);
  if (datasource == null) {
    if (environment.type != EnvironmentType.production) {
      return DevelopmentAuthRepository(
        secureStorage: ref.watch(authSecureStorageProvider),
        biometricAuthService: ref.watch(biometricAuthServiceProvider),
      );
    }

    return const UnconfiguredAuthRepository();
  }

  return AuthRepositoryImpl(
    datasource: datasource,
    secureStorage: ref.watch(authSecureStorageProvider),
    biometricAuthService: ref.watch(biometricAuthServiceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final loginWithBiometricsUseCaseProvider = Provider<LoginWithBiometricsUseCase>(
  (ref) {
    return LoginWithBiometricsUseCase(ref.watch(authRepositoryProvider));
  },
);
