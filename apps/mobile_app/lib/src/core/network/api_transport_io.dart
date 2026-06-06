import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'api_transport_base.dart';

Future<ApiTransport> createApiTransport() async {
  final certificateBytes = await rootBundle.load('assets/certs/dev-cert.pem');
  final securityContext = SecurityContext(withTrustedRoots: false);
  securityContext.setTrustedCertificatesBytes(
    certificateBytes.buffer.asUint8List(),
  );

  final httpClient = HttpClient(context: securityContext)
    ..connectionTimeout = const Duration(seconds: 10)
    ..idleTimeout = const Duration(seconds: 15);

  return _IoApiTransport(httpClient);
}

class _IoApiTransport implements ApiTransport {
  const _IoApiTransport(this._httpClient);

  final HttpClient _httpClient;

  @override
  Future<ApiResponse> sendJson({
    required String method,
    required Uri uri,
    Object? payload,
    Map<String, String>? headers,
  }) async {
    final request = await _httpClient.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);

    headers?.forEach(request.headers.set);

    if (payload != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
    }

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();

    return ApiResponse(statusCode: response.statusCode, body: body);
  }
}
