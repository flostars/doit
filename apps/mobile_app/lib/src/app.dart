import 'package:flutter/material.dart';

import 'features/auth/data/auth_gateway.dart';
import 'features/auth/data/http_auth_gateway.dart';
import 'features/auth/domain/auth_session.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';

class DoitApp extends StatefulWidget {
  const DoitApp({super.key, this.authGateway});

  final AuthGateway? authGateway;

  @override
  State<DoitApp> createState() => _DoitAppState();
}

class _DoitAppState extends State<DoitApp> {
  late final Future<AuthGateway> _authGatewayFuture = widget.authGateway != null
      ? Future<AuthGateway>.value(widget.authGateway!)
      : HttpAuthGateway.create();

  AuthSession? _session;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'doit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A936F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: Color(0xFFD5DDD7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(color: Color(0xFF1A936F), width: 1.5),
          ),
        ),
      ),
      home: FutureBuilder<AuthGateway>(
        future: _authGatewayFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _AppErrorScreen();
          }

          if (!snapshot.hasData) {
            return const _AppLoadingScreen();
          }

          final authGateway = snapshot.data!;
          if (_session != null) {
            final session = _session!;
            return HomePage(
              authGateway: authGateway,
              session: session,
              onLogout: () => _logout(authGateway, session),
            );
          }

          return LoginPage(
            authGateway: authGateway,
            onAuthenticated: (session) {
              setState(() {
                _session = session;
              });
            },
          );
        },
      ),
    );
  }

  Future<void> _logout(AuthGateway authGateway, AuthSession session) async {
    try {
      await authGateway.logout(accessToken: session.accessToken);
    } on AuthException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _session = null;
    });
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _AppErrorScreen extends StatelessWidget {
  const _AppErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Не вдалося підготувати захищений API-клієнт.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
