import 'package:flutter/material.dart';
import '../models/flight_offer.dart';
import '../services/flight_booking_service.dart';

class FlightBookingViewModel with ChangeNotifier {
  final FlightBookingService _bookingService = FlightBookingService();

  FlightOffer? _selectedOffer;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _bookingResult;

  // Getters
  FlightOffer? get selectedOffer => _selectedOffer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get bookingResult => _bookingResult;

  // Setters
  void selectOffer(FlightOffer offer) {
    _selectedOffer = offer;
    notifyListeners();
  }

  /// Book a flight with full details
  Future<void> bookFlight({
    required Map<String, dynamic> flightOffer,
    required List<Map<String, dynamic>> travelers,
    required List<Map<String, dynamic>> contacts,
    required List<Map<String, dynamic>> formOfPayments,
    Map<String, dynamic>? paymentInfo,
    bool issueTicket = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would require a search request - in real app, you'd store this
      final dummySearchRequest = {
        'originDestinations': [],
        'travelers': {'adt': 1, 'chd': 0, 'inf': 0},
      };

      _bookingResult = await _bookingService.bookFlight(
        searchRequest: dummySearchRequest,
        selectedOffer: flightOffer,
        travelers: travelers,
        contacts: contacts,
        formOfPayments: formOfPayments,
        paymentInfo: paymentInfo,
        issueTicket: issueTicket,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Quick book method
  Future<void> quickBook({
    required Map<String, dynamic> flightOffer,
    required String travelerName,
    required String email,
    required String phone,
  }) async {
    final travelers = [
      {
        'id': '1',
        'dateOfBirth': '1990-01-01',
        'gender': 'MALE',
        'name': {
          'firstName': travelerName.split(' ').first,
          'lastName': travelerName.split(' ').last,
        },
        'contact': {
          'emailAddress': email,
          'phones': [
            {
              'deviceType': 'MOBILE',
              'countryCallingCode': '27',
              'number': phone,
            },
          ],
        },
      },
    ];

    await bookFlight(
      flightOffer: flightOffer,
      travelers: travelers,
      contacts: [], // Will be created in quickBook
      formOfPayments: [
        {
          'other': {
            'method': 'CASH',
            'flightOfferIds': [1],
          },
        },
      ],
      issueTicket: true,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearBookingResult() {
    _bookingResult = null;
    notifyListeners();
  }
}
