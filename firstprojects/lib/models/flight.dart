class Flight {
  final int id;
  final String from;
  final String to;
  final double price;
  final String date;
  final String time;
  final String carrier;
  final String carrierCode;
  final String carrierLogo;

  Flight({
    required this.id,
    required this.from,
    required this.to,
    required this.price,
    required this.date,
    required this.time,
    required this.carrier,
    required this.carrierCode,
    required this.carrierLogo,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      price: json['price']?.toDouble() ?? 0.0,
      date: json['date'],
      time: json['time'],
      carrier: json['carrier'],
      carrierCode: json['carrierCode'],
      carrierLogo: json['carrierLogo'],
    );
  }

  String get formattedPrice => '\$${price.toInt()}';
  String get flightNumber => '$carrierCode${id.toString().padLeft(3, '0')}';
}
