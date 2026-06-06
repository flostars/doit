class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.expiresAt,
    required this.userId,
    required this.username,
    required this.displayName,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
    );
  }

  final String accessToken;
  final DateTime expiresAt;
  final String userId;
  final String username;
  final String displayName;
}
