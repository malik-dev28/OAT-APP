// filepath: c:\AndroidStudioProjects\hello_world\lib\utils\http\http_client.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Minimal wrapper around `package:http` to centralize timeouts and error handling.
class HttpClient {
  static const Duration _timeout = Duration(seconds: 15);

  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final future = http.get(uri, headers: headers);
    return future.timeout(
      _timeout,
      onTimeout: () {
        throw TimeoutException(
          'Request timed out after ${_timeout.inSeconds} seconds',
        );
      },
    );
  }

  static Future<http.Response> postJson(
    Uri uri,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final Map<String, String> h = {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
    final future = http.post(uri, headers: h, body: json.encode(body));
    return future.timeout(
      _timeout,
      onTimeout: () {
        throw TimeoutException(
          'Request timed out after ${_timeout.inSeconds} seconds',
        );
      },
    );
  }

  // You can add put/delete helpers here as needed.
}
