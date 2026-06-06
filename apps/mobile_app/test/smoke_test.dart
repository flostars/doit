import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/src/app.dart';
import 'package:mobile_app/src/features/auth/data/auth_gateway.dart';
import 'package:mobile_app/src/features/auth/domain/auth_session.dart';
import 'package:mobile_app/src/features/auth/domain/user_profile.dart';

void main() {
  testWidgets('renders secure login screen', (tester) async {
    await tester.pumpWidget(DoitApp(authGateway: _FakeAuthGateway()));
    await tester.pumpAndSettle();

    expect(find.text('Secure Access'), findsOneWidget);
    expect(find.text('Вхід'), findsOneWidget);
    expect(find.text('Реєстрація'), findsOneWidget);
    expect(find.text('Електронна пошта'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Увійти'), findsOneWidget);
  });
}

class _FakeAuthGateway implements AuthGateway {
  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    return AuthSession(
      accessToken: 'token',
      expiresAt: DateTime.utc(2026, 6, 5, 12),
      userId: 'user-1',
      username: username,
      displayName: 'Demo User',
    );
  }

  @override
  Future<UserProfile> fetchCurrentUser({required String accessToken}) async {
    return UserProfile(
      userId: 'user-1',
      username: 'demo@doit.local',
      displayName: 'Demo User',
      registeredAt: DateTime.utc(2026, 6, 5, 11),
    );
  }

  @override
  Future<void> logout({required String accessToken}) async {}

  @override
  Future<AuthSession> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    return AuthSession(
      accessToken: 'token',
      expiresAt: DateTime.utc(2026, 6, 5, 12),
      userId: 'user-2',
      username: username,
      displayName: displayName,
    );
  }
}
