class AuthSessionDto {
  const AuthSessionDto({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(
      userId: json['user_id'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  final String userId;
  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
