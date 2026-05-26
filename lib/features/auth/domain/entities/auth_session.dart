class AuthSession {
  const AuthSession({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String userId;
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  bool get hasValidAccessToken {
    if (accessToken.isEmpty || expiresAt == null) {
      return accessToken.isNotEmpty;
    }

    return DateTime.now().isBefore(expiresAt!);
  }
}
