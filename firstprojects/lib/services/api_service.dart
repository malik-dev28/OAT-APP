// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String baseUrl = dotenv.get('BASE_URL');
  String? _accessToken;
  String? _clientRef;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void setClientRef(String clientRef) {
    _clientRef = clientRef;
  }

  Map<String, String> _getHeaders({
    bool includeAuth = true,
    bool includeClientRef = false,
  }) {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (includeClientRef && _clientRef != null) {
      headers['ama-client-ref'] = _clientRef!;
    }

    return headers;
  }

  // Login - Step 1: Send OTP
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Login - Step 2: Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['accessToken'];
        return data;
      } else {
        throw Exception('OTP verification failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('OTP verification error: $e');
    }
  }

  // Flight Search
  Future<Map<String, dynamic>> flightSearch(
    Map<String, dynamic> searchData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/flight/shopping'),
        headers: _getHeaders(),
        body: jsonEncode(searchData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store client reference for subsequent requests
        if (data['data']?['amadeusRawJson']?['amadeusRequestId'] != null) {
          _clientRef = data['data']['amadeusRawJson']['amadeusRequestId'];
        }
        return data;
      } else {
        throw Exception('Flight search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Flight search error: $e');
    }
  }

  // Get Offer Price
  Future<Map<String, dynamic>> getOfferPrice(
    Map<String, dynamic> flightOffer,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/flight-offers/offer-price'),
        headers: _getHeaders(includeClientRef: true),
        body: jsonEncode(flightOffer),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Offer price failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Offer price error: $e');
    }
  }

  // Create Order
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData, {
    bool issueTicket = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/flight-offers/create-order?issue-ticket=$issueTicket',
        ),
        headers: _getHeaders(includeClientRef: true),
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Create order failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create order error: $e');
    }
  }

  // Issue Ticket
  Future<Map<String, dynamic>> issueTicket(
    String flightOrderId,
    Map<String, dynamic> paymentData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/flight/ticket/amadeus-hold-Booking'),
        headers: _getHeaders(),
        body: jsonEncode({
          ...paymentData,
          'amaClientRef': _clientRef,
          'flightOrderId': flightOrderId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Issue ticket failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Issue ticket error: $e');
    }
  }
}
