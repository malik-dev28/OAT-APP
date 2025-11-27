class OrderCreationRequest {
  final List<Map<String, dynamic>> flightOffers;
  final List<Map<String, dynamic>> travelers;
  final List<Map<String, dynamic>> contacts;
  final List<Map<String, dynamic>> formOfPayments;
  final Map<String, dynamic>? paymentInfo;

  OrderCreationRequest({
    required this.flightOffers,
    required this.travelers,
    required this.contacts,
    required this.formOfPayments,
    this.paymentInfo,
  });

  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{
      'flightOffers': flightOffers,
      'travelers': travelers,
      'contacts': contacts,
      'formOfPayments': formOfPayments,
    };

    if (paymentInfo != null) {
      body['paymentInfo'] = paymentInfo;
    }

    return body;
  }
}
