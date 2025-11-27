class OfferPriceRequest {
  final Map<String, dynamic> flightOffer;

  OfferPriceRequest({required this.flightOffer});

  Map<String, dynamic> toJson() {
    return flightOffer;
  }

  factory OfferPriceRequest.fromFlightOffer(Map<String, dynamic> flightOffer) {
    return OfferPriceRequest(flightOffer: flightOffer);
  }
}
