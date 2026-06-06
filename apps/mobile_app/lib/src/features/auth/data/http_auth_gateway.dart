import 'dart:convert';

import '../../../core/network/api_transport.dart';
import '../../../core/network/api_transport_base.dart';
import '../domain/auth_session.dart';
import '../domain/user_profile.dart';
import 'auth_gateway.dart';

class HttpAuthGateway implements AuthGateway {
  HttpAuthGateway._(this._transport, this._baseUrl);

  static const String defaultBaseUrl = String.fromEnvironment(
    'DOIT_API_BASE_URL',
    defaultValue: 'https://127.0.0.1:8443',
  );

  final ApiTransport _transport;
  final String _baseUrl;

  static Future<HttpAuthGateway> create({
    String baseUrl = defaultBaseUrl,
  }) async {
    final transport = await createApiTransport();
    return HttpAuthGateway._(transport, baseUrl);
  }

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    return _authenticate(
      path: '/api/v1/auth/login',
      payload: {'username': username, 'password': password},
      successStatusCodes: const {200},
      registration: false,
    );
  }

  @override
  Future<AuthSession> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    return _authenticate(
      path: '/api/v1/auth/register',
      payload: {
        'username': username,
        'password': password,
        'displayName': displayName,
      },
      successStatusCodes: const {201},
      registration: true,
    );
  }

  @override
  Future<UserProfile> fetchCurrentUser({required String accessToken}) async {
    try {
      final response = await _transport.sendJson(
        method: 'GET',
        uri: Uri.parse('$_baseUrl/api/v1/users/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final body = _decodeBody(response.body);
      if (response.statusCode == 200) {
        return UserProfile.fromJson(body);
      }

      throw AuthException(
        message: _profileErrorMessageFor(response.statusCode, body),
        statusCode: response.statusCode,
      );
    } on AuthException {
      rethrow;
    } on FormatException {
      throw const AuthException(
        message: 'Сервер повернув невалідну відповідь.',
      );
    } catch (error) {
      if (error is UnsupportedError) {
        throw AuthException(
          message: error.message ?? 'Поточна платформа не підтримується.',
        );
      }

      throw const AuthException(
        message: 'Не вдалося встановити захищене з’єднання із сервером.',
      );
    }
  }

  @override
  Future<void> logout({required String accessToken}) async {
    try {
      final response = await _transport.sendJson(
        method: 'POST',
        uri: Uri.parse('$_baseUrl/api/v1/auth/logout'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 204) {
        return;
      }

      final body = _decodeBody(response.body);
      throw AuthException(
        message: _logoutErrorMessageFor(response.statusCode, body),
        statusCode: response.statusCode,
      );
    } on AuthException {
      rethrow;
    } on FormatException {
      throw const AuthException(
        message: 'Сервер повернув невалідну відповідь.',
      );
    } catch (error) {
      if (error is UnsupportedError) {
        throw AuthException(
          message: error.message ?? 'Поточна платформа не підтримується.',
        );
      }

      throw const AuthException(
        message: 'Не вдалося завершити захищену сесію на сервері.',
      );
    }
  }

  Future<AuthSession> _authenticate({
    required String path,
    required Map<String, Object?> payload,
    required Set<int> successStatusCodes,
    required bool registration,
  }) async {
    try {
      final response = await _transport.sendJson(
        method: 'POST',
        uri: Uri.parse('$_baseUrl$path'),
        payload: payload,
      );

      final body = _decodeBody(response.body);
      if (successStatusCodes.contains(response.statusCode)) {
        return AuthSession.fromJson(body);
      }

      throw AuthException(
        message: _authErrorMessageFor(
          response.statusCode,
          body,
          registration: registration,
        ),
        statusCode: response.statusCode,
      );
    } on AuthException {
      rethrow;
    } on FormatException {
      throw const AuthException(
        message: 'Сервер повернув невалідну відповідь.',
      );
    } catch (error) {
      if (error is UnsupportedError) {
        throw AuthException(
          message: error.message ?? 'Поточна платформа не підтримується.',
        );
      }

      throw const AuthException(
        message: 'Не вдалося встановити захищене з’єднання із сервером.',
      );
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }

    throw const FormatException('Expected a JSON object.');
  }

  String _authErrorMessageFor(
    int statusCode,
    Map<String, dynamic> body, {
    required bool registration,
  }) {
    final defaultMessage = switch (statusCode) {
      400 =>
        registration
            ? 'Перевір поля реєстрації. Пароль має містити щонайменше 8 символів.'
            : 'Заповни логін і пароль.',
      401 => 'Невірний логін або пароль.',
      409 => 'Користувач з такою поштою вже існує.',
      _ =>
        registration
            ? 'Не вдалося створити акаунт.'
            : 'Не вдалося виконати вхід.',
    };

    return _messageFromBody(body) ?? defaultMessage;
  }

  String _profileErrorMessageFor(int statusCode, Map<String, dynamic> body) {
    final defaultMessage = switch (statusCode) {
      401 => 'Сесія недійсна або протермінована.',
      404 => 'Профіль користувача не знайдено.',
      _ => 'Не вдалося завантажити захищений профіль.',
    };

    return _messageFromBody(body) ?? defaultMessage;
  }

  String _logoutErrorMessageFor(int statusCode, Map<String, dynamic> body) {
    final defaultMessage = switch (statusCode) {
      401 => 'Сесію вже завершено або токен недійсний.',
      _ => 'Не вдалося завершити сесію на сервері.',
    };

    return _messageFromBody(body) ?? defaultMessage;
  }

  String? _messageFromBody(Map<String, dynamic> body) {
    final detail = body['detail'] ?? body['message'] ?? body['title'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }

    return null;
  }
}
