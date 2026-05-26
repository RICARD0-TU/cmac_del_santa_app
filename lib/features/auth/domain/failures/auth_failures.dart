import '../../../../core/errors/failure.dart';

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
    : super(message: 'Las credenciales ingresadas no son validas.');
}

class AuthConfigurationFailure extends AuthFailure {
  const AuthConfigurationFailure()
    : super(
        message:
            'Supabase no esta configurado. Define SUPABASE_URL y SUPABASE_ANON_KEY.',
      );
}

class BiometricUnavailableFailure extends AuthFailure {
  const BiometricUnavailableFailure()
    : super(message: 'La autenticacion biometrica no esta disponible.');
}
