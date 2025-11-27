import '../api/api_service.dart';
import '../models/flight_offer.dart';
import '../models/flight_search_request.dart';
import '../models/offer_price_request.dart';
import '../models/order_creation_request.dart';

class FlightOfferRepository {
  /// Search for flights
  Future<List<FlightOffer>> searchFlights(FlightSearchRequest request) async {
    try {
      final response = await ApiService.searchFlights(request);
      return ApiService.parseFlightOffers(response);
    } catch (e) {
      throw Exception('Failed to search flights: $e');
    }
  }

  /// Get detailed pricing for a flight offer
  Future<FlightOffer?> getOfferPrice(OfferPriceRequest request) async {
    try {
      final response = await ApiService.getOfferPrice(request);
      return ApiService.parseOfferPriceResponse(response);
    } catch (e) {
      throw Exception('Failed to get offer price: $e');
    }
  }

  /// Create a flight order
  Future<Map<String, dynamic>> createOrder(OrderCreationRequest request, {bool issueTicket = false}) async {
    try {
      return await ApiService.createOrder(request, issueTicket: issueTicket);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Issue ticket for a booked order
  Future<Map<String, dynamic>> issueTicket({
    required String flightOrderId,
    required List<Map<String, dynamic>> formOfPayments,
  }) async {
    try {
      return await ApiService.issueTicket(
        flightOrderId: flightOrderId,
        formOfPayments: formOfPayments,
      );
    } catch (e) {
      throw Exception('Failed to issue ticket: $e');
    }
  }
}