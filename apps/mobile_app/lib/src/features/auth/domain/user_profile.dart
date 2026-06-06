class UserProfile {
  const UserProfile({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.registeredAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );
  }

  final String userId;
  final String username;
  final String displayName;
  final DateTime registeredAt;
}
