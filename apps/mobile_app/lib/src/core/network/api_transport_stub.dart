import 'api_transport_base.dart';

Future<ApiTransport> createApiTransport() async => _UnsupportedApiTransport();

class _UnsupportedApiTransport implements ApiTransport {
  @override
  Future<ApiResponse> sendJson({
    required String method,
    required Uri uri,
    Object? payload,
    Map<String, String>? headers,
  }) {
    throw UnsupportedError(
      'This platform is not supported for secure API calls.',
    );
  }
}
