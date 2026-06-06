import 'api_transport_base.dart';
import 'api_transport_stub.dart'
    if (dart.library.io) 'api_transport_io.dart'
    if (dart.library.html) 'api_transport_web.dart'
    as transport_impl;

Future<ApiTransport> createApiTransport() =>
    transport_impl.createApiTransport();
