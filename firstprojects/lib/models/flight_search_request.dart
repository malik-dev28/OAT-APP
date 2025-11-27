class FlightSearchRequest {
  final List<OriginDestination> originDestinations;
  final Travellers travellers;

  FlightSearchRequest({
    required this.originDestinations,
    required this.travellers,
  });

  Map<String, dynamic> toJson() => {
    'originDestinations': originDestinations.map((o) => o.toJson()).toList(),
    'travellers': travellers.toJson(),
  };
}

class OriginDestination {
  final FlightPoint departure;
  final FlightPoint arrival;

  OriginDestination({required this.departure, required this.arrival});

  Map<String, dynamic> toJson() => {
    'departure': departure.toJson(),
    'arrival': arrival.toJson(),
  };
}

class FlightPoint {
  final String airportCode;
  final String? date; // date is optional for arrival

  FlightPoint({required this.airportCode, this.date});

  Map<String, dynamic> toJson() => {
    if (airportCode != null) 'airportCode': airportCode,
    if (date != null) 'date': date,
  };
}

class Travellers {
  final int adt;
  final int chd;
  final int inf;

  Travellers({required this.adt, required this.chd, required this.inf});

  Map<String, dynamic> toJson() => {'adt': adt, 'chd': chd, 'inf': inf};
}
