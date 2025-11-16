import 'dart:convert';
import 'package:http/http.dart' as http;

class FlightService {
  static Future<Map<String, dynamic>> fetchFlights({
    required String from,
    required String to,
    required String date,
  }) async {
    final url =
        "http://156.67.31.137:3000/api/flights?from=$from&to=$to&date=$date";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        if (decoded is Map && decoded.containsKey("flights")) {
          return {"data": decoded["flights"], "error": null};
        } else if (decoded is List) {
          return {"data": decoded, "error": null};
        } else {
          return {"data": [], "error": "Invalid API format"};
        }
      }

      return {"data": [], "error": "API Error: ${res.statusCode}"};
    } catch (e) {
      return {"data": [], "error": "Network error: $e"};
    }
  }
}
