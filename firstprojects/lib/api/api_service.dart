// filepath: c:\AndroidStudioProjects\hello_world\lib\api\api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/flight_offer.dart';
import '../models/flight_search_request.dart';
import '../models/offer_price_request.dart';
import '../models/order_creation_request.dart';
import '../utils/http/http_client.dart';

class ApiService {
  static const String _baseUrl = 'http://35.179.4.119/ai/api';
  static String? _authToken;
  static String? _clientRef;

  /// Set authentication token for API calls
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Set client reference for session continuity
  static void setClientRef(String clientRef) {
    _clientRef = clientRef;
  }

  /// Get common headers for authenticated requests
  static Map<String, String> _getHeaders({bool includeClientRef = false}) {
    final headers = {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };

    if (includeClientRef && _clientRef != null) {
      headers['ama-client-ref'] = _clientRef!;
    }

    return headers;
  }

  /// Fetch a list of passengers (users) from the sample API.
  static Future<List<FlightOffer>> fetchPassengers() async {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/users');
    final response = await HttpClient.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((e) => FlightOffer.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load passengers: ${response.statusCode}');
    }
  }

  /// Flight Search API
  static Future<Map<String, dynamic>> searchFlights(
    FlightSearchRequest req,
  ) async {
    final uri = Uri.parse('$_baseUrl/flight/shopping');
    final response = await HttpClient.postJson(
      uri,
      req.toJson(),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Flight search failed: ${response.statusCode}');
    }
  }

  /// Offer Price API - Get detailed pricing for a flight offer
  static Future<Map<String, dynamic>> getOfferPrice(
    OfferPriceRequest request,
  ) async {
    final uri = Uri.parse('$_baseUrl/flight-offers/offer-price');
    final response = await HttpClient.postJson(
      uri,
      request.toJson(),
      headers: _getHeaders(includeClientRef: true),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Offer price request failed: ${response.statusCode}');
    }
  }

  /// Create Order API - Book the flight
  static Future<Map<String, dynamic>> createOrder(
    OrderCreationRequest request, {
    bool issueTicket = false,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/flight-offers/create-order?issue-ticket=$issueTicket',
    );
    final response = await HttpClient.postJson(
      uri,
      request.toJson(),
      headers: _getHeaders(includeClientRef: true),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Order creation failed: ${response.statusCode}');
    }
  }

  /// Issue Ticket API - Finalize booking and issue tickets
  static Future<Map<String, dynamic>> issueTicket({
    required String flightOrderId,
    required List<Map<String, dynamic>> formOfPayments,
  }) async {
    final uri = Uri.parse('$_baseUrl/flight/ticket/amadeus-hold-Booking');
    final requestBody = {
      'formOfPayments': formOfPayments,
      'amaClientRef': _clientRef,
      'flightOrderId': flightOrderId,
    };

    final response = await HttpClient.postJson(
      uri,
      requestBody,
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Ticket issuance failed: ${response.statusCode}');
    }
  }

  /// Parse a real flight search response into a list of FlightOffer
  static List<FlightOffer> parseFlightOffers(Map<String, dynamic> response) {
    try {
      final data = response['data'] as Map<String, dynamic>?;
      final am = data?['amadeusRawJson'] as Map<String, dynamic>?;
      final list = am?['data'] as List<dynamic>? ?? [];
      final dictionaries = am?['dictionaries'] as Map<String, dynamic>?;
      final carriersMap = dictionaries?['carriers'] as Map<String, dynamic>?;
      final currenciesMap =
          dictionaries?['currencies'] as Map<String, dynamic>?;

      return list
          .map(
            (e) => FlightOffer.fromMap(
              e as Map<String, dynamic>,
              carriers: carriersMap,
              currencies: currenciesMap,
            ),
          )
          .toList();
    } catch (e) {
      return <FlightOffer>[];
    }
  }

  /// Parse offer price response
  static FlightOffer? parseOfferPriceResponse(Map<String, dynamic> response) {
    try {
      final data = response['data'] as Map<String, dynamic>?;
      final flightOffers = data?['data']?['flightOffers'] as List<dynamic>?;

      if (flightOffers != null && flightOffers.isNotEmpty) {
        final offerData = flightOffers.first as Map<String, dynamic>;
        final dictionaries = data?['dictionaries'] as Map<String, dynamic>?;

        return FlightOffer.fromMap(
          offerData,
          carriers: dictionaries?['carriers'] as Map<String, dynamic>?,
          currencies: null, // Price already included in response
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
