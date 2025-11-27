import '../models/flight_offer.dart';
import '../models/flight_search_request.dart';
import '../models/offer_price_request.dart';
import '../models/order_creation_request.dart';
import '../repositories/flight_offer_repository.dart';

class FlightBookingService {
  final FlightOfferRepository _repository = FlightOfferRepository();

  /// Complete flight booking flow
  Future<Map<String, dynamic>> bookFlight({
    required FlightSearchRequest searchRequest,
    required Map<String, dynamic> selectedOffer,
    required List<Map<String, dynamic>> travelers,
    required List<Map<String, dynamic>> contacts,
    required List<Map<String, dynamic>> formOfPayments,
    Map<String, dynamic>? paymentInfo,
    bool issueTicket = false,
  }) async {
    try {
      // Step 1: Get detailed pricing
      final offerPriceRequest = OfferPriceRequest.fromFlightOffer(
        selectedOffer,
      );
      final pricedOffer = await _repository.getOfferPrice(offerPriceRequest);

      if (pricedOffer == null) {
        throw Exception('Failed to get offer pricing');
      }

      // Step 2: Create order
      final orderRequest = OrderCreationRequest(
        flightOffers: [selectedOffer],
        travelers: travelers,
        contacts: contacts,
        paymentInfo: paymentInfo,
        formOfPayments: formOfPayments,
      );

      final orderResult = await _repository.createOrder(
        orderRequest,
        issueTicket: issueTicket,
      );

      return orderResult;
    } catch (e) {
      throw Exception('Booking failed: $e');
    }
  }

  /// Quick book with minimal parameters
  Future<Map<String, dynamic>> quickBook({
    required Map<String, dynamic> flightOffer,
    required List<Map<String, dynamic>> travelers,
    required String contactEmail,
    required String contactPhone,
  }) async {
    final contacts = [
      {
        'addresseeName': {
          'firstName': travelers.first['name']?['firstName'] ?? 'Traveler',
          'lastName': travelers.first['name']?['lastName'] ?? '',
        },
        'purpose': 'STANDARD',
        'phones': [
          {
            'deviceType': 'MOBILE',
            'countryCallingCode': '27', // Adjust as needed
            'number': contactPhone,
          },
        ],
        'emailAddress': contactEmail,
      },
    ];

    final formOfPayments = [
      {
        'other': {
          'method': 'CASH',
          'flightOfferIds': [1],
        },
      },
    ];

    return await bookFlight(
      searchRequest: FlightSearchRequest(
        originDestinations: [],
        travelers: {'adt': 1, 'chd': 0, 'inf': 0},
      ),
      selectedOffer: flightOffer,
      travelers: travelers,
      contacts: contacts,
      formOfPayments: formOfPayments,
      issueTicket: true,
    );
  }
}
