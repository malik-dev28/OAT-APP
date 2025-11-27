import 'dart:convert';

import '../utils/http/http_client.dart';

class AuthService {
  static const String _base = 'http://35.179.4.119/ai/api/auth';

  /// Perform static login (sends email/password). Returns server map.
  static Future<Map<String, dynamic>> login() async {
    final uri = Uri.parse('$_base/login');
    final body = {'email': 'stadesse.t@gmail.com', 'password': 'password123'};
    final resp = await HttpClient.postJson(uri, body);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: ${resp.statusCode}');
  }

  /// Verify OTP (static) and return the response map (contains accessToken).
  static Future<Map<String, dynamic>> verifyOtp() async {
    final uri = Uri.parse('$_base/verify-otp');
    final body = {'email': 'stadesse.t@gmail.com', 'otp': '123456'};
    final resp = await HttpClient.postJson(uri, body);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('OTP verify failed: ${resp.statusCode}');
  }
}
