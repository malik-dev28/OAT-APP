// filepath: c:\AndroidStudioProjects\hello_world\lib\repositories\auth_repository.dart
import 'dart:convert';

import '../utils/http/http_client.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login();
  Future<Map<String, dynamic>> verifyOtp();
}

class HttpAuthRepository implements AuthRepository {
  static const String _base = 'http://35.179.4.119/ai/api/auth';
  const HttpAuthRepository();

  @override
  Future<Map<String, dynamic>> login() async {
    final uri = Uri.parse('$_base/login');
    final body = {'email': 'stadesse.t@gmail.com', 'password': 'password123'};
    final resp = await HttpClient.postJson(uri, body);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: ${resp.statusCode}');
  }

  @override
  Future<Map<String, dynamic>> verifyOtp() async {
    final uri = Uri.parse('$_base/verify-otp');
    final body = {'email': 'stadesse.t@gmail.com', 'otp': '123456'};
    final resp = await HttpClient.postJson(uri, body);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('OTP verify failed: ${resp.statusCode}');
  }
}
