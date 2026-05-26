import 'package:local_auth/local_auth.dart';

abstract interface class BiometricAuthService {
  Future<bool> canAuthenticate();
  Future<bool> authenticateForLogin();
}

class LocalBiometricAuthService implements BiometricAuthService {
  LocalBiometricAuthService(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  @override
  Future<bool> canAuthenticate() async {
    final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    final isDeviceSupported = await _localAuthentication.isDeviceSupported();
    return canCheckBiometrics && isDeviceSupported;
  }

  @override
  Future<bool> authenticateForLogin() {
    return _localAuthentication.authenticate(
      localizedReason: 'Confirma tu identidad para ingresar a CMAC Del Santa',
      biometricOnly: false,
      persistAcrossBackgrounding: true,
    );
  }
}
