class FlightOffer {
  final String id;
  final String totalPrice;
  final int numberOfBookableSeats;
  final List<Itinerary> itineraries;
  final String? carrierName; // human-readable carrier (from dictionaries)
  final String? currencyCode;
  final String? currencyName;

  FlightOffer({
    required this.id,
    required this.totalPrice,
    required this.numberOfBookableSeats,
    required this.itineraries,
    this.carrierName,
    this.currencyCode,
    this.currencyName,
  });

  factory FlightOffer.fromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? carriers,
    Map<String, dynamic>? currencies,
  }) {
    final price = map['price'] as Map<String, dynamic>?;
    final total = price != null ? (price['total']?.toString() ?? '') : '';
    final itinerariesData = map['itineraries'] as List<dynamic>? ?? [];
    final itineraries = itinerariesData
        .map((it) => Itinerary.fromMap(it as Map<String, dynamic>))
        .toList();

    // determine primary carrier code from first segment (if available)
    String? primaryCarrierCode;
    if (itineraries.isNotEmpty && itineraries.first.segments.isNotEmpty) {
      primaryCarrierCode = itineraries.first.segments.first.carrierCode;
    }

    final carrierName = primaryCarrierCode != null
        ? (carriers != null
              ? carriers[primaryCarrierCode]?.toString() ?? primaryCarrierCode
              : primaryCarrierCode)
        : null;

    final currencyCode = price != null ? price['currency']?.toString() : null;
    final currencyName = currencyCode != null && currencies != null
        ? currencies[currencyCode]?.toString()
        : null;

    return FlightOffer(
      id: map['id']?.toString() ?? '',
      totalPrice: total,
      numberOfBookableSeats: (map['numberOfBookableSeats'] is int)
          ? map['numberOfBookableSeats'] as int
          : int.tryParse(map['numberOfBookableSeats']?.toString() ?? '0') ?? 0,
      itineraries: itineraries,
      carrierName: carrierName,
      currencyCode: currencyCode,
      currencyName: currencyName,
    );
  }
}

class Itinerary {
  final String duration;
  final List<Segment> segments;
  Itinerary({required this.duration, required this.segments});

  factory Itinerary.fromMap(Map<String, dynamic> map) {
    final segmentsData = map['segments'] as List<dynamic>? ?? [];
    final segments = segmentsData
        .map((s) => Segment.fromMap(s as Map<String, dynamic>))
        .toList();
    return Itinerary(
      duration: map['duration']?.toString() ?? '',
      segments: segments,
    );
  }
}

class Segment {
  final FlightPointAt departure;
  final FlightPointAt arrival;
  final String carrierCode;
  final String number;

  Segment({
    required this.departure,
    required this.arrival,
    required this.carrierCode,
    required this.number,
  });

  factory Segment.fromMap(Map<String, dynamic> map) {
    return Segment(
      departure: FlightPointAt.fromMap(
        map['departure'] as Map<String, dynamic>,
      ),
      arrival: FlightPointAt.fromMap(map['arrival'] as Map<String, dynamic>),
      carrierCode: map['carrierCode']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
    );
  }
}

class FlightPointAt {
  final String iataCode;
  final String? terminal;
  final String? at;
  final DateTime? atParsed;
  FlightPointAt({
    required this.iataCode,
    this.terminal,
    this.at,
    this.atParsed,
  });

  factory FlightPointAt.fromMap(Map<String, dynamic> map) {
    final atStr = map['at']?.toString();
    DateTime? parsed;
    if (atStr != null) {
      parsed = DateTime.tryParse(atStr);
    }
    return FlightPointAt(
      iataCode: map['iataCode']?.toString() ?? '',
      terminal: map['terminal']?.toString(),
      at: atStr,
      atParsed: parsed,
    );
  }
}
