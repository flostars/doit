import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/src/app.dart';
import 'package:mobile_app/src/features/auth/data/auth_gateway.dart';
import 'package:mobile_app/src/features/auth/domain/auth_session.dart';
import 'package:mobile_app/src/features/auth/domain/user_profile.dart';

void main() {
  testWidgets('successful login opens authenticated home', (tester) async {
    final authGateway = _FakeAuthGateway();
    await tester.pumpWidget(DoitApp(authGateway: authGateway));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'demo@doit.local');
    await tester.enterText(find.byType(TextFormField).last, 'ChangeMe123!');
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(find.text('Привіт, Demo User'), findsOneWidget);
    expect(find.text('Захищений профіль'), findsOneWidget);
    expect(find.textContaining('demo@doit.local'), findsOneWidget);
  });

  testWidgets('failed login shows api error', (tester) async {
    await tester.pumpWidget(
      DoitApp(authGateway: _FakeAuthGateway(shouldFail: true)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'demo@doit.local');
    await tester.enterText(find.byType(TextFormField).last, 'wrong-password');
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(find.text('Невірний логін або пароль.'), findsOneWidget);
  });

  testWidgets('registration mode creates a new account', (tester) async {
    final authGateway = _FakeAuthGateway();
    await tester.pumpWidget(DoitApp(authGateway: authGateway));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Реєстрація'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'new@doit.local');
    await tester.enterText(find.byType(TextFormField).at(1), 'New User');
    await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass123!');
    await tester.tap(find.text('Створити акаунт'));
    await tester.pumpAndSettle();

    expect(find.text('Привіт, New User'), findsOneWidget);
    expect(find.textContaining('new@doit.local'), findsOneWidget);
  });

  testWidgets('logout returns user to login screen', (tester) async {
    final authGateway = _FakeAuthGateway();
    await tester.pumpWidget(DoitApp(authGateway: authGateway));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'demo@doit.local');
    await tester.enterText(find.byType(TextFormField).last, 'ChangeMe123!');
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Вийти'));
    await tester.pumpAndSettle();

    expect(find.text('Secure Access'), findsOneWidget);
    expect(authGateway.logoutCallCount, 1);
  });
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway({this.shouldFail = false});

  final bool shouldFail;
  String _username = 'demo@doit.local';
  String _displayName = 'Demo User';
  int logoutCallCount = 0;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    if (shouldFail) {
      throw const AuthException(message: 'Невірний логін або пароль.');
    }

    _username = username;
    _displayName = 'Demo User';

    return AuthSession(
      accessToken: 'token',
      expiresAt: DateTime.utc(2026, 6, 5, 12),
      userId: 'user-1',
      username: username,
      displayName: _displayName,
    );
  }

  @override
  Future<UserProfile> fetchCurrentUser({required String accessToken}) async {
    return UserProfile(
      userId: 'user-1',
      username: _username,
      displayName: _displayName,
      registeredAt: DateTime.utc(2026, 6, 5, 11),
    );
  }

  @override
  Future<void> logout({required String accessToken}) async {
    logoutCallCount += 1;
  }

  @override
  Future<AuthSession> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    _username = username;
    _displayName = displayName;

    return AuthSession(
      accessToken: 'token',
      expiresAt: DateTime.utc(2026, 6, 5, 12),
      userId: 'user-2',
      username: username,
      displayName: displayName,
    );
  }
}
