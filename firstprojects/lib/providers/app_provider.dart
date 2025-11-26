// lib/providers/app_provider.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  String? _accessToken;
  Map<String, dynamic>? _flightOffers;
  Map<String, dynamic>? _selectedOffer;
  Map<String, dynamic>? _offerPrice;
  Map<String, dynamic>? _createdOrder;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get flightOffers => _flightOffers;
  Map<String, dynamic>? get selectedOffer => _selectedOffer;
  Map<String, dynamic>? get offerPrice => _offerPrice;
  Map<String, dynamic>? get createdOrder => _createdOrder;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Auto Login with OTP
  Future<void> autoLogin() async {
    _setLoading(true);
    _setError(null);

    try {
      // Step 1: Send OTP
      final loginResponse = await _apiService.login(
        'stadesse.t@gmail.com',
        'password123',
      );

      // Step 2: Verify OTP (using default OTP from Postman)
      final otpResponse = await _apiService.verifyOtp(
        'stadesse.t@gmail.com',
        '123456',
      );

      _accessToken = otpResponse['accessToken'];
      _apiService.setAccessToken(_accessToken!);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Flight Search
  Future<void> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    required String returnDate,
    int adults = 1,
    int children = 0,
    int infants = 0,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final searchData = {
        'originDestinations': [
          {
            'departure': {'airportCode': origin, 'date': departureDate},
            'arrival': {'airportCode': destination},
          },
          {
            'departure': {'airportCode': destination, 'date': returnDate},
            'arrival': {'airportCode': origin},
          },
        ],
        'travellers': {'adt': adults, 'chd': children, 'inf': infants},
      };

      final response = await _apiService.flightSearch(searchData);
      _flightOffers = response['data']['amadeusRawJson'];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get Offer Price
  Future<void> getOfferPriceDetails(Map<String, dynamic> offer) async {
    _setLoading(true);
    _setError(null);
    _selectedOffer = offer;

    try {
      final response = await _apiService.getOfferPrice(offer);
      _offerPrice = response['data'];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create Order
  Future<void> createFlightOrder(Map<String, dynamic> travelerData) async {
    _setLoading(true);
    _setError(null);

    try {
      final orderData = {
        'flightOffers': [_selectedOffer],
        'travelers': [travelerData],
        'contacts': [
          {
            'addresseeName': {
              'firstName': travelerData['name']['firstName'],
              'lastName': travelerData['name']['lastName'],
            },
            'purpose': 'STANDARD',
            'phones': travelerData['contact']['phones'],
            'emailAddress': travelerData['contact']['emailAddress'],
            'address': {
              'lines': ['173 Oxford Road Rosebank'],
              'postalCode': '2196',
              'cityName': 'Johannesburg',
              'countryCode': 'ZA',
            },
          },
        ],
        'formOfPayments': [
          {
            'other': {
              'method': 'CASH',
              'flightOfferIds': [1],
            },
          },
        ],
      };

      final response = await _apiService.createOrder(
        orderData,
        issueTicket: false,
      );
      _createdOrder = response['data'];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Clear data
  void clearData() {
    _flightOffers = null;
    _selectedOffer = null;
    _offerPrice = null;
    _createdOrder = null;
    _error = null;
    notifyListeners();
  }
}
