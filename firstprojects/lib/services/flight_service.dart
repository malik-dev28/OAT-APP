import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flight_availability_app/models/flight.dart';

class FlightService {
  static const String baseUrl = 'http://156.67.31.137:3000';

  static Future<List<Flight>> searchFlights({
    required String origin,
    required String destination,
    required String date,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/flights?from=$origin&to=$destination&date=$date'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> flightsJson = data['flights'];

        return flightsJson.map((json) => Flight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load flights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}
