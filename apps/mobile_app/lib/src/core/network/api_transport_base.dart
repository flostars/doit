abstract class ApiTransport {
  Future<ApiResponse> sendJson({
    required String method,
    required Uri uri,
    Object? payload,
    Map<String, String>? headers,
  });
}

class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}
