import 'dart:math';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiChatbotService {
  // Airport database with full names and countries
  static final Map<String, Map<String, String>> _airportDatabase = {
    'NYC': {
      'name': 'New York City (Multiple Airports)',
      'city': 'New York',
      'country': 'United States'
    },
    'JFK': {
      'name': 'John F. Kennedy International Airport',
      'city': 'New York',
      'country': 'United States'
    },
    'LAX': {
      'name': 'Los Angeles International Airport',
      'city': 'Los Angeles',
      'country': 'United States'
    },
    'DXB': {
      'name': 'Dubai International Airport',
      'city': 'Dubai',
      'country': 'United Arab Emirates'
    },
    'ADD': {
      'name': 'Addis Ababa Bole International Airport',
      'city': 'Addis Ababa',
      'country': 'Ethiopia'
    },
    'LHR': {
      'name': 'London Heathrow Airport',
      'city': 'London',
      'country': 'United Kingdom'
    },
    'CDG': {
      'name': 'Paris Charles de Gaulle Airport',
      'city': 'Paris',
      'country': 'France'
    },
    'FRA': {
      'name': 'Frankfurt Airport',
      'city': 'Frankfurt',
      'country': 'Germany'
    },
    'IST': {
      'name': 'Istanbul Airport',
      'city': 'Istanbul',
      'country': 'Turkey'
    },
    'NRT': {
      'name': 'Narita International Airport',
      'city': 'Tokyo',
      'country': 'Japan'
    },
    'HND': {'name': 'Haneda Airport', 'city': 'Tokyo', 'country': 'Japan'},
    'ICN': {
      'name': 'Incheon International Airport',
      'city': 'Seoul',
      'country': 'South Korea'
    },
    'SIN': {
      'name': 'Singapore Changi Airport',
      'city': 'Singapore',
      'country': 'Singapore'
    },
    'BKK': {
      'name': 'Suvarnabhumi Airport',
      'city': 'Bangkok',
      'country': 'Thailand'
    },
    'DEL': {
      'name': 'Indira Gandhi International Airport',
      'city': 'Delhi',
      'country': 'India'
    },
    'SYD': {
      'name': 'Sydney Kingsford Smith Airport',
      'city': 'Sydney',
      'country': 'Australia'
    },
    'YYZ': {
      'name': 'Toronto Pearson International Airport',
      'city': 'Toronto',
      'country': 'Canada'
    },
    'AMS': {
      'name': 'Amsterdam Airport Schiphol',
      'city': 'Amsterdam',
      'country': 'Netherlands'
    },
    'MAD': {
      'name': 'Adolfo Suárez Madrid–Barajas Airport',
      'city': 'Madrid',
      'country': 'Spain'
    },
    'MIA': {
      'name': 'Miami International Airport',
      'city': 'Miami',
      'country': 'United States'
    },
    'GRU': {
      'name': 'São Paulo/Guarulhos International Airport',
      'city': 'São Paulo',
      'country': 'Brazil'
    },
    'LIS': {'name': 'Lisbon Airport', 'city': 'Lisbon', 'country': 'Portugal'},
    'MNL': {
      'name': 'Ninoy Aquino International Airport',
      'city': 'Manila',
      'country': 'Philippines'
    },
    'PEK': {
      'name': 'Beijing Capital International Airport',
      'city': 'Beijing',
      'country': 'China'
    },
    'PVG': {
      'name': 'Shanghai Pudong International Airport',
      'city': 'Shanghai',
      'country': 'China'
    },
    'BOM': {
      'name': 'Chhatrapati Shivaji Maharaj International Airport',
      'city': 'Mumbai',
      'country': 'India'
    },
    'FCO': {
      'name': 'Leonardo da Vinci–Fiumicino Airport',
      'city': 'Rome',
      'country': 'Italy'
    },
    'CAI': {
      'name': 'Cairo International Airport',
      'city': 'Cairo',
      'country': 'Egypt'
    },
    'JNB': {
      'name': 'O.R. Tambo International Airport',
      'city': 'Johannesburg',
      'country': 'South Africa'
    },
    'NBO': {
      'name': 'Jomo Kenyatta International Airport',
      'city': 'Nairobi',
      'country': 'Kenya'
    },
    // Ethiopian domestic airports
    'DIR': {
      'name': 'Aba Tenna Dejazmach Yilma International Airport',
      'city': 'Dire Dawa',
      'country': 'Ethiopia'
    },
    'MQX': {
      'name': 'Alula Aba Nega Airport',
      'city': 'Mekelle',
      'country': 'Ethiopia'
    },
    'BJR': {
      'name': 'Bahir Dar Airport',
      'city': 'Bahir Dar',
      'country': 'Ethiopia'
    },
    'GDQ': {'name': 'Gondar Airport', 'city': 'Gondar', 'country': 'Ethiopia'},
    'LLI': {
      'name': 'Lalibela Airport',
      'city': 'Lalibela',
      'country': 'Ethiopia'
    },
    'AXU': {'name': 'Axum Airport', 'city': 'Axum', 'country': 'Ethiopia'},
  };

  // Airline database with headquarters
  static final Map<String, Map<String, String>> _airlineDatabase = {
    'ET': {
      'name': 'Ethiopian Airlines',
      'country': 'Ethiopia',
      'hub': 'ADD',
      'ranking': 'Best African Airline'
    },
    'QR': {
      'name': 'Qatar Airways',
      'country': 'Qatar',
      'hub': 'DOH',
      'ranking': '#1 World Best 2025'
    },
    'SQ': {
      'name': 'Singapore Airlines',
      'country': 'Singapore',
      'hub': 'SIN',
      'ranking': '#2 World Best 2025'
    },
    'CX': {
      'name': 'Cathay Pacific',
      'country': 'Hong Kong',
      'hub': 'HKG',
      'ranking': '#3 World Best 2025'
    },
    'EK': {
      'name': 'Emirates',
      'country': 'UAE',
      'hub': 'DXB',
      'ranking': '#4 World Best 2025'
    },
    'NH': {
      'name': 'ANA All Nippon Airways',
      'country': 'Japan',
      'hub': 'HND',
      'ranking': '#5 World Best 2025'
    },
    'TK': {
      'name': 'Turkish Airlines',
      'country': 'Turkey',
      'hub': 'IST',
      'ranking': '#6 World Best 2025'
    },
    'KE': {
      'name': 'Korean Air',
      'country': 'South Korea',
      'hub': 'ICN',
      'ranking': '#7 World Best 2025'
    },
    'AF': {
      'name': 'Air France',
      'country': 'France',
      'hub': 'CDG',
      'ranking': '#8 World Best 2025'
    },
    'JL': {
      'name': 'Japan Airlines',
      'country': 'Japan',
      'hub': 'HND',
      'ranking': '#9 World Best 2025'
    },
    'HU': {
      'name': 'Hainan Airlines',
      'country': 'China',
      'hub': 'PEK',
      'ranking': '#10 World Best 2025'
    },
    'LX': {
      'name': 'Swiss International Air Lines',
      'country': 'Switzerland',
      'hub': 'ZRH',
      'ranking': '#11 World Best 2025'
    },
    'BR': {
      'name': 'EVA Air',
      'country': 'Taiwan',
      'hub': 'TPE',
      'ranking': '#12 World Best 2025'
    },
    'BA': {
      'name': 'British Airways',
      'country': 'United Kingdom',
      'hub': 'LHR',
      'ranking': '#13 World Best 2025'
    },
    'QF': {
      'name': 'Qantas Airways',
      'country': 'Australia',
      'hub': 'SYD',
      'ranking': '#14 World Best 2025'
    },
    'LH': {
      'name': 'Lufthansa',
      'country': 'Germany',
      'hub': 'FRA',
      'ranking': '#15 World Best 2025'
    },
    'VS': {
      'name': 'Virgin Atlantic',
      'country': 'United Kingdom',
      'hub': 'LHR',
      'ranking': '#16 World Best 2025'
    },
    'SV': {
      'name': 'Saudi Arabian Airlines',
      'country': 'Saudi Arabia',
      'hub': 'JED',
      'ranking': '#17 World Best 2025'
    },
    'JX': {
      'name': 'STARLUX Airlines',
      'country': 'Taiwan',
      'hub': 'TPE',
      'ranking': '#18 World Best 2025'
    },
    'AC': {
      'name': 'Air Canada',
      'country': 'Canada',
      'hub': 'YYZ',
      'ranking': '#19 World Best 2025'
    },
    'IB': {
      'name': 'Iberia',
      'country': 'Spain',
      'hub': 'MAD',
      'ranking': '#20 World Best 2025'
    },
    'AA': {
      'name': 'American Airlines',
      'country': 'United States',
      'hub': 'DFW',
      'ranking': 'Major US Carrier'
    },
    'DL': {
      'name': 'Delta Air Lines',
      'country': 'United States',
      'hub': 'ATL',
      'ranking': 'Major US Carrier'
    },
    'UA': {
      'name': 'United Airlines',
      'country': 'United States',
      'hub': 'ORD',
      'ranking': 'Major US Carrier'
    },
    'B6': {
      'name': 'JetBlue Airways',
      'country': 'United States',
      'hub': 'JFK',
      'ranking': 'US Low-Cost Carrier'
    },
    'AS': {
      'name': 'Alaska Airlines',
      'country': 'United States',
      'hub': 'SEA',
      'ranking': 'US West Coast Carrier'
    },
  };

  // Popular routes with descriptions
  static final List<Map<String, dynamic>> _popularRoutes = [
    {
      'from': 'NYC',
      'to': 'LAX',
      'description': 'Transcontinental US route with multiple daily flights',
      'bestPrice': '\$279',
      'bestAirline': 'JetBlue Airways'
    },
    {
      'from': 'LAX',
      'to': 'DXB',
      'description': 'Long-haul international to Middle East hub',
      'bestPrice': '\$590',
      'bestAirline': 'Turkish Airlines'
    },
    {
      'from': 'DXB',
      'to': 'ADD',
      'description': 'Middle East to African hub connection',
      'bestPrice': '\$390',
      'bestAirline': 'Air Arabia'
    },
    {
      'from': 'ADD',
      'to': 'NBO',
      'description': 'East African regional connection',
      'bestPrice': '\$220',
      'bestAirline': 'Ethiopian Airlines'
    },
    {
      'from': 'JFK',
      'to': 'LHR',
      'description': 'Premium transatlantic business route',
      'bestPrice': '\$650',
      'bestAirline': 'British Airways'
    },
    {
      'from': 'DXB',
      'to': 'LHR',
      'description': 'Middle East to Europe premium route',
      'bestPrice': '\$480',
      'bestAirline': 'Emirates'
    },
    {
      'from': 'ADD',
      'to': 'LHR',
      'description': 'African hub to Europe',
      'bestPrice': '\$720',
      'bestAirline': 'Ethiopian Airlines'
    },
    {
      'from': 'ADD',
      'to': 'CDG',
      'description': 'African hub to European capital',
      'bestPrice': '\$690',
      'bestAirline': 'Ethiopian Airlines'
    },
    {
      'from': 'ADD',
      'to': 'IST',
      'description': 'African hub to Turkish gateway',
      'bestPrice': '\$450',
      'bestAirline': 'Turkish Airlines'
    },
    {
      'from': 'ADD',
      'to': 'BKK',
      'description': 'African hub to Southeast Asia',
      'bestPrice': '\$580',
      'bestAirline': 'Ethiopian Airlines'
    },
  ];

  static String getResponse(String userMessage, List<ChatMessage> chatHistory) {
    final message = userMessage.toLowerCase().trim();

    // Airport code explanation
    if (_isAirportCodeQuery(message)) {
      return _handleAirportCodeQuery(message);
    }

    // Airline information
    if (_isAirlineQuery(message)) {
      return _handleAirlineQuery(message);
    }

    // Route suggestions
    if (_isRouteQuery(message)) {
      return _handleRouteQuery(message);
    }

    // Price comparisons
    if (_isPriceQuery(message)) {
      return _handlePriceQuery(message);
    }

    // Ethiopian Airlines specific
    if (_isEthiopianQuery(message)) {
      return _handleEthiopianQuery(message);
    }

    // Greeting
    if (_isGreeting(message)) {
      return _handleGreeting();
    }

    // Default response
    return _handleDefaultQuery(message);
  }

  static bool _isAirportCodeQuery(String message) {
    final codes = [
      'nyc',
      'lax',
      'dxb',
      'add',
      'lhr',
      'cdg',
      'fra',
      'ist',
      'nrt',
      'hnd',
      'icn',
      'sin',
      'bkk',
      'del',
      'syd',
      'yyz'
    ];
    return codes.any((code) => message.contains(code)) ||
        RegExp(r'[A-Z]{3}').hasMatch(message.toUpperCase()) &&
            message.length == 3;
  }

  static bool _isAirlineQuery(String message) {
    final airlines = [
      'ethiopian',
      'qatar',
      'emirates',
      'singapore',
      'turkish',
      'british',
      'lufthansa',
      'air france',
      'qantas',
      'american',
      'delta',
      'united'
    ];
    return airlines.any((airline) => message.contains(airline));
  }

  static bool _isRouteQuery(String message) {
    return message.contains('route') ||
        message.contains('fly from') ||
        message.contains('to ') ||
        message.contains('best flight') ||
        message.contains('suggest');
  }

  static bool _isPriceQuery(String message) {
    return message.contains('price') ||
        message.contains('cheap') ||
        message.contains('expensive') ||
        message.contains('cost') ||
        message.contains('how much');
  }

  static bool _isEthiopianQuery(String message) {
    return message.contains('ethiopia') ||
        message.contains('addis') ||
        message.contains('bole') ||
        message.contains('domestic') ||
        message.contains('local flight');
  }

  static bool _isGreeting(String message) {
    return message.contains('hello') ||
        message.contains('hi') ||
        message.contains('hey') ||
        message.contains('good morning') ||
        message.contains('good afternoon');
  }

  static String _handleAirportCodeQuery(String message) {
    // Extract potential airport codes (3 uppercase letters)
    final codes = RegExp(r'[A-Z]{3}')
        .allMatches(message.toUpperCase())
        .map((m) => m.group(0)!)
        .toList();

    if (codes.isEmpty)
      return "I couldn't find any airport codes in your message. Airport codes are 3-letter codes like NYC, LAX, DXB.";

    final response = StringBuffer();
    response.writeln("🏢 **Airport Information:**\n");

    for (final code in codes.take(3)) {
      // Limit to 3 codes to avoid too long responses
      if (_airportDatabase.containsKey(code)) {
        final airport = _airportDatabase[code]!;
        response.writeln("**$code**: ${airport['name']}");
        response.writeln("📍 ${airport['city']}, ${airport['country']}");
        response.writeln("");
      } else {
        response.writeln("**$code**: Airport code not found in database");
        response.writeln("");
      }
    }

    response.writeln(
        "💡 *Need flight information for these airports? Ask me about routes or prices!*");

    return response.toString();
  }

  static String _handleAirlineQuery(String message) {
    final response = StringBuffer();
    response.writeln("✈️ **Airline Information:**\n");

    // Find matching airlines
    final matchedAirlines = _airlineDatabase.entries.where((entry) {
      final airline = entry.value;
      return message.contains(airline['name']!.toLowerCase()) ||
          message.contains(airline['country']!.toLowerCase());
    }).toList();

    if (matchedAirlines.isNotEmpty) {
      for (final entry in matchedAirlines.take(2)) {
        final airline = entry.value;
        response.writeln("**${airline['name']}** (${entry.key})");
        response.writeln("🇺🇳 Headquarters: ${airline['country']}");
        response.writeln(
            "🏠 Main Hub: ${_airportDatabase[airline['hub']]?['name'] ?? airline['hub']}");
        response.writeln("🏆 ${airline['ranking']}");
        response.writeln("");
      }
    } else {
      // Show top airlines if no specific match
      response.writeln("**Top 5 Airlines 2025:**");
      response.writeln("1. 🇶🇦 Qatar Airways - World's Best Airline");
      response.writeln("2. 🇸🇬 Singapore Airlines - Best Cabin Crew");
      response.writeln("3. 🇭🇰 Cathay Pacific - Best Business Class");
      response.writeln("4. 🇦🇪 Emirates - Best Inflight Entertainment");
      response.writeln("5. 🇪🇹 Ethiopian Airlines - Best African Airline");
      response.writeln("");
    }

    response.writeln(
        "💡 *Ask about specific airlines like 'Tell me about Ethiopian Airlines'*");

    return response.toString();
  }

  static String _handleRouteQuery(String message) {
    final response = StringBuffer();
    response.writeln("🛫 **Popular Flight Routes:**\n");

    // Extract potential from/to cities
    final fromMatch =
        RegExp(r'from\s+([A-Z]{3})').firstMatch(message.toUpperCase());
    final toMatch =
        RegExp(r'to\s+([A-Z]{3})').firstMatch(message.toUpperCase());

    if (fromMatch != null && toMatch != null) {
      final from = fromMatch.group(1)!;
      final to = toMatch.group(1)!;

      response.writeln(
          "**${_airportDatabase[from]?['city'] ?? from} → ${_airportDatabase[to]?['city'] ?? to}**");

      // Find matching route
      final route = _popularRoutes.firstWhere(
        (r) => r['from'] == from && r['to'] == to,
        orElse: () => {},
      );

      if (route.isNotEmpty) {
        response.writeln("${route['description']}");
        response.writeln("💰 Best Price: ${route['bestPrice']}");
        response.writeln("✈️ Recommended: ${route['bestAirline']}");
      } else {
        response.writeln("🌟 New route suggestion!");
        response.writeln("💡 Check our flight search for real-time prices");
      }
    } else {
      // Show popular routes
      response.writeln("**Top Recommended Routes:**");
      for (final route in _popularRoutes.take(5)) {
        final fromCity =
            _airportDatabase[route['from']]?['city'] ?? route['from'];
        final toCity = _airportDatabase[route['to']]?['city'] ?? route['to'];
        response.writeln(
            "• **$fromCity → $toCity** - ${route['bestPrice']} (${route['bestAirline']})");
      }
    }

    response.writeln("");
    response.writeln(
        "💡 *Try: 'flights from NYC to LAX' or 'best routes from Addis Ababa'*");

    return response.toString();
  }

  static String _handlePriceQuery(String message) {
    final response = StringBuffer();
    response.writeln("💰 **Price Information:**\n");

    // Sample price ranges based on distance
    final priceRanges = {
      'Domestic (US)': '\$150-\$400',
      'Domestic (Ethiopia)': '\$50-\$200',
      'Short-haul International': '\$200-\$600',
      'Medium-haul International': '\$400-\$900',
      'Long-haul International': '\$600-\$1,500+',
    };

    response.writeln("**Typical Price Ranges:**");
    for (final entry in priceRanges.entries) {
      response.writeln("• ${entry.key}: ${entry.value}");
    }

    response.writeln("");
    response.writeln("**Money-Saving Tips:**");
    response
        .writeln("• 🕐 Book 2-3 months in advance for international flights");
    response.writeln("• 📱 Use our app for exclusive mobile-only deals");
    response.writeln("• 🔄 Be flexible with dates (+/- 3 days)");
    response.writeln("• 🌙 Consider red-eye flights for better prices");

    response.writeln("");
    response.writeln("💡 *Search specific routes for real-time pricing*");

    return response.toString();
  }

  static String _handleEthiopianQuery(String message) {
    final response = StringBuffer();
    response.writeln("🇪🇹 **Ethiopian Airlines & Destinations:**\n");

    response.writeln("**Ethiopian Airlines (ET)**");
    response.writeln("🏆 Best African Airline 2025");
    response.writeln("🌍 Hub: Addis Ababa Bole Airport (ADD)");
    response.writeln("🛩️ Fleet: 140+ aircraft including Dreamliners");
    response.writeln("🎖️ Star Alliance Member since 2011");
    response.writeln("");

    if (message.contains('domestic') || message.contains('local')) {
      response.writeln("**Ethiopian Domestic Routes from ADD:**");
      final domesticAirports = [
        'DIR',
        'MQX',
        'BJR',
        'GDQ',
        'LLI',
        'AXU',
        'AMH',
        'AWA'
      ];
      for (final code in domesticAirports) {
        final airport = _airportDatabase[code]!;
        response.writeln(
            "• **${airport['city']}** ($code) - Multiple daily flights");
      }
    } else {
      response.writeln("**Popular International Routes from ADD:**");
      response.writeln("• 🌍 Dubai (DXB) - 4+ daily flights");
      response.writeln("• 🇺🇸 Washington D.C. (IAD) - Daily");
      response.writeln("• 🇨🇳 Beijing (PEK) - 5x weekly");
      response.writeln("• 🇹🇷 Istanbul (IST) - 2x daily");
      response.writeln("• 🇬🇧 London (LHR) - Daily");
      response.writeln("• 🇰🇪 Nairobi (NBO) - 3x daily");
    }

    response.writeln("");
    response.writeln(
        "💡 *Ask about specific Ethiopian Airlines routes or domestic flights*");

    return response.toString();
  }

  static String _handleGreeting() {
    return """👋 **Hello! I'm your Flight Assistant!**

I can help you with:

🏢 **Airport Codes** - "What is DXB?"
✈️ **Airline Info** - "Tell me about Ethiopian Airlines"
🛫 **Route Suggestions** - "Best flights from NYC"
💰 **Price Information** - "Cheapest time to fly"
🇪🇹 **Ethiopian Travel** - "Domestic flights in Ethiopia"

What would you like to know about flights today?""";
  }

  static String _handleDefaultQuery(String message) {
    return """🤔 I'm not sure I understand. Here's what I can help with:

Try asking me about:
• "What does LAX mean?"
• "Tell me about Qatar Airways"
• "Best flights from Addis Ababa"
• "Price of NYC to LAX"
• "Ethiopian Airlines domestic routes"
• "Top airlines 2025"

Or use the quick search examples above! ✈️""";
  }
}
