import 'package:flutter/material.dart';

import '../data/auth_gateway.dart';
import '../domain/auth_session.dart';

enum _AuthMode { login, register }

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.authGateway,
    required this.onAuthenticated,
    super.key,
  });

  final AuthGateway authGateway;
  final ValueChanged<AuthSession> onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final session = switch (_mode) {
        _AuthMode.login => await widget.authGateway.login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
        _AuthMode.register => await widget.authGateway.register(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        ),
      };
      if (!mounted) {
        return;
      }
      widget.onAuthenticated(session);
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRegisterMode = _mode == _AuthMode.register;

    return Scaffold(
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Secure Access',
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Вхід і реєстрація працюють через HTTPS API, а після авторизації клієнт ходить у захищені bearer endpoint-и.',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            SegmentedButton<_AuthMode>(
                              segments: const [
                                ButtonSegment<_AuthMode>(
                                  value: _AuthMode.login,
                                  label: Text('Вхід'),
                                  icon: Icon(Icons.login_outlined),
                                ),
                                ButtonSegment<_AuthMode>(
                                  value: _AuthMode.register,
                                  label: Text('Реєстрація'),
                                  icon: Icon(Icons.person_add_alt_1_outlined),
                                ),
                              ],
                              selected: {_mode},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _mode = selection.first;
                                  _errorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _usernameController,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                labelText: 'Електронна пошта',
                                hintText: 'demo@doit.local',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введи логін.';
                                }
                                return null;
                              },
                            ),
                            if (isRegisterMode) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _displayNameController,
                                autofillHints: const [AutofillHints.name],
                                decoration: const InputDecoration(
                                  labelText: 'Імʼя користувача',
                                  hintText: 'New User',
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (isRegisterMode &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Введи імʼя користувача.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              autofillHints: const [AutofillHints.password],
                              decoration: const InputDecoration(
                                labelText: 'Пароль',
                                hintText: 'Мінімум 8 символів',
                              ),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введи пароль.';
                                }
                                if (value.length < 8) {
                                  return 'Пароль має містити щонайменше 8 символів.';
                                }
                                return null;
                              },
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE9E5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Text(
                                    _errorMessage!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF8A2E1D),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _isSubmitting ? null : _submit,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  child: Text(
                                    _isSubmitting
                                        ? 'Перевірка...'
                                        : isRegisterMode
                                        ? 'Створити акаунт'
                                        : 'Увійти',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isRegisterMode
                                  ? 'Реєстрація одразу повертає access token і відкриває захищений профіль.'
                                  : 'Dev-облікові дані задаються на сервері через DOIT_AUTH_USERNAME і DOIT_AUTH_PASSWORD.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5FAF6), Color(0xFFE0F0E8), Color(0xFFFDF7EE)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: const [
          _Glow(
            alignment: Alignment.topLeft,
            color: Color(0x551A936F),
            size: 260,
          ),
          _Glow(
            alignment: Alignment.bottomRight,
            color: Color(0x44F4A259),
            size: 320,
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
