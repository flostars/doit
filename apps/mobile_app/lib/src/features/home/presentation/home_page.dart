import 'package:flutter/material.dart';
import 'details_page.dart';

import '../../auth/data/auth_gateway.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/domain/user_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.authGateway,
    required this.session,
    required this.onLogout,
    super.key,
  });

  final AuthGateway authGateway;
  final AuthSession session;
  final Future<void> Function() onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<UserProfile> _profileFuture = widget.authGateway
      .fetchCurrentUser(accessToken: widget.session.accessToken);
  bool _isLoggingOut = false;
  String? _logoutError;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
      _logoutError = null;
    });

    try {
      await widget.onLogout();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _logoutError = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('doit'),
        actions: [
          TextButton(
            onPressed: _isLoggingOut ? null : _handleLogout,
            child: Text(_isLoggingOut ? 'Вихід...' : 'Вийти'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_logoutError != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _logoutError!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF8A2E1D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Привіт, ${widget.session.displayName}',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Сеанс активний до ${_formatDateTime(widget.session.expiresAt.toLocal())}. '
                      'Після входу клієнт викликає захищений bearer endpoint, а вихід ревокує токен на сервері.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4EE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Токен: ${_tokenPreview(widget.session.accessToken)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Захищений профіль', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            FutureBuilder<UserProfile>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        snapshot.error.toString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF8A2E1D),
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final profile = snapshot.data!;
                return Card(
                  child: ListTile(
                    title: Text(profile.displayName),
                    subtitle: Text(
                      '${profile.username}\nЗареєстровано: ${_formatDateTime(profile.registeredAt.toLocal())}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.verified_user_outlined),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Monorepo scaffold ready', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              'This app is prepared for parallel work with the Java backend.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const _AreaCard(
              title: 'mobile_app',
              description: 'Flutter UI, navigation, state management, tests',
            ),
            const SizedBox(height: 12),
            const _AreaCard(
              title: 'api-server',
              description: 'Spring Boot API, domain logic, persistence',
            ),
            const SizedBox(height: 12),
            const _AreaCard(
              title: 'contracts',
              description: 'Shared API contract and integration rules',
            ),
            const SizedBox(height: 32), // Відступ перед кнопкою
            // ДОДАЄМО КНОПКУ:
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.arrow_forward), // Іконка стрілочки
                label: const Text('Перейти на деталі'), // Текст на кнопці
                onPressed: () {
                  // ЦЕЙ БЛОК ВИКЛИКАЄТЬСЯ ПРИ НАЖАТТІ
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const DetailsPage(), // Наш новий екран
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.${value.year} $hour:$minute';
  }

  String _tokenPreview(String token) {
    if (token.length <= 16) {
      return token;
    }

    return '${token.substring(0, 16)}...';
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title), subtitle: Text(description)),
    );
  }
}
