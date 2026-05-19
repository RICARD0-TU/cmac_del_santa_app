import '../constants/app_constants.dart';

class SessionSecurityPolicy {
  const SessionSecurityPolicy({
    this.timeout = const Duration(minutes: AppConstants.sessionTimeoutMinutes),
    this.requireBiometricsForSensitiveActions = true,
  });

  final Duration timeout;
  final bool requireBiometricsForSensitiveActions;
}
