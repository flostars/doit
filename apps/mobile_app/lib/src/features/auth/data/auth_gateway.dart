import '../domain/auth_session.dart';
import '../domain/user_profile.dart';

abstract interface class AuthGateway {
  Future<AuthSession> login({
    required String username,
    required String password,
  });

  Future<AuthSession> register({
    required String username,
    required String password,
    required String displayName,
  });

  Future<UserProfile> fetchCurrentUser({required String accessToken});

  Future<void> logout({required String accessToken});
}

class AuthException implements Exception {
  const AuthException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
