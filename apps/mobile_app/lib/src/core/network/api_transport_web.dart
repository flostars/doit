// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'api_transport_base.dart';

Future<ApiTransport> createApiTransport() async => const _WebApiTransport();

class _WebApiTransport implements ApiTransport {
  const _WebApiTransport();

  @override
  Future<ApiResponse> sendJson({
    required String method,
    required Uri uri,
    Object? payload,
    Map<String, String>? headers,
  }) async {
    final completer = Completer<ApiResponse>();
    final request = html.HttpRequest();

    request.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Network request failed.'));
      }
    });

    request.onLoadEnd.first.then((_) {
      if (!completer.isCompleted) {
        completer.complete(
          ApiResponse(
            statusCode: request.status ?? 0,
            body: request.responseText ?? '',
          ),
        );
      }
    });

    request.open(method, uri.toString());
    request.setRequestHeader('Accept', 'application/json');

    headers?.forEach(request.setRequestHeader);

    if (payload != null) {
      request.setRequestHeader('Content-Type', 'application/json');
      request.send(jsonEncode(payload));
    } else {
      request.send();
    }

    return completer.future;
  }
}
