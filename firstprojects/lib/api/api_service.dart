// filepath: c:\AndroidStudioProjects\hello_world\lib\api\api_service.dart
import 'dart:convert';

import '../models/flight_offer.dart';
import '../models/flight_search_request.dart';
import '../utils/http/http_client.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  /// Fetch a list of passengers (users) from the sample API.
  static Future<List<FlightOffer>> fetchPassengers() async {
    final uri = Uri.parse('$_baseUrl/users');

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

  /// Post a flight search request to the server and return the raw response body as a Map.
  /// NOTE: Using a mock endpoint for demo (`/posts`). Replace with your real search endpoint.
  static Future<Map<String, dynamic>> searchFlights(
    FlightSearchRequest req,
  ) async {
    final uri = Uri.parse('$_baseUrl/posts');
    final response = await HttpClient.postJson(uri, req.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Flight search failed: ${response.statusCode}');
    }
  }

  /// Parse a real flight search response (amadeusRawJson.data) into a list of FlightOffer.
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
}
