import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/flight_offer.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<FlightOffer>> fetchPassengers() async {
    final uri = Uri.parse('$_baseUrl/users');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((e) => FlightOffer.fromMap(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load passengers: ${response.statusCode}');
    }
  }
}
