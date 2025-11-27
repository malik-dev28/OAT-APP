// filepath: c:\AndroidStudioProjects\hello_world\lib\repositories\flight_repository.dart
import 'dart:convert';

import '../models/flight_search_request.dart';
import '../utils/http/http_client.dart';

abstract class FlightRepository {
  Future<Map<String, dynamic>> searchFlights(
    FlightSearchRequest req,
    String accessToken,
  );
}

class HttpFlightRepository implements FlightRepository {
  static const String _searchUrl = 'http://35.179.4.119/ai/api/flight/shopping';
  const HttpFlightRepository();

  @override
  Future<Map<String, dynamic>> searchFlights(
    FlightSearchRequest req,
    String accessToken,
  ) async {
    final uri = Uri.parse(_searchUrl);
    final resp = await HttpClient.postJson(
      uri,
      req.toJson(),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Flight search failed: ${resp.statusCode}');
  }
}
