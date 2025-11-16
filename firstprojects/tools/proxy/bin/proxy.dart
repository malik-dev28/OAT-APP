import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:http/http.dart' as http;

// Target backend (the user's API host)
const String backendHost = 'http://156.67.31.137:3000';

Response _optionsResponse() => Response.ok('', headers: {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, POST, OPTIONS, PUT, DELETE',
      'access-control-allow-headers': 'Origin, Content-Type, Accept',
    });

Future<Response> _proxyHandler(Request request) async {
  if (request.method == 'OPTIONS') return _optionsResponse();

  // build target URI
  final backendUri = Uri.parse(backendHost).replace(
    path: request.requestedUri.path,
    queryParameters: request.requestedUri.queryParameters.isEmpty
        ? null
        : request.requestedUri.queryParameters,
  );

  try {
    // Only forwarding GET for now (that's what the app uses).
    final proxied = await http.get(backendUri);

    final headers = <String, String>{
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, POST, OPTIONS, PUT, DELETE',
      'access-control-allow-headers': 'Origin, Content-Type, Accept',
    };

    // preserve content-type if present
    if (proxied.headers['content-type'] != null) {
      headers['content-type'] = proxied.headers['content-type']!;
    }

    return Response(proxied.statusCode, body: proxied.body, headers: headers);
  } catch (e) {
    return Response.internalServerError(body: 'Proxy error: $e', headers: {
      'access-control-allow-origin': '*',
    });
  }
}

void main(List<String> args) async {
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_proxyHandler);

  final ip = InternetAddress.loopbackIPv4;
  const port = 8080;

  final server = await io.serve(handler, ip, port);
  print('CORS proxy listening on http://${server.address.host}:${server.port}');
}
