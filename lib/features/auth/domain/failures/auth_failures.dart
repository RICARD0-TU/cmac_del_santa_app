import '../../../../core/errors/failure.dart';

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
    : super(message: 'Las credenciales ingresadas no son validas.');
}
