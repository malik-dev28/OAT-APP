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
  // Common misspellings and corrections
  static final Map<String, String> _spellingCorrections = {
    'addias': 'addis', 'addia': 'addis', 'adiss': 'addis',
    'ethopia': 'ethiopia', 'ethopian': 'ethiopian',
    'qatter': 'qatar', 'emirats': 'emirates', 'singapor': 'singapore',
    'turkey': 'turkish', 'britan': 'british', 'lufthansa': 'lufthansa',
    'qantas': 'qantas', 'america': 'american', 'dubay': 'dubai',
    'newyork': 'new york', 'losangeles': 'los angeles', 'londan': 'london',
  };

  // Airport database
  static final Map<String, Map<String, String>> _airportDatabase = {
    'NYC': {'name': 'New York City Airports', 'city': 'New York', 'country': 'USA'},
    'JFK': {'name': 'John F. Kennedy Airport', 'city': 'New York', 'country': 'USA'},
    'LAX': {'name': 'Los Angeles International', 'city': 'Los Angeles', 'country': 'USA'},
    'DXB': {'name': 'Dubai International Airport', 'city': 'Dubai', 'country': 'UAE'},
    'ADD': {'name': 'Addis Ababa Bole Airport', 'city': 'Addis Ababa', 'country': 'Ethiopia'},
    'LHR': {'name': 'London Heathrow Airport', 'city': 'London', 'country': 'UK'},
    'CDG': {'name': 'Paris Charles de Gaulle', 'city': 'Paris', 'country': 'France'},
    'FRA': {'name': 'Frankfurt Airport', 'city': 'Frankfurt', 'country': 'Germany'},
    'IST': {'name': 'Istanbul Airport', 'city': 'Istanbul', 'country': 'Turkey'},
    'NRT': {'name': 'Tokyo Narita Airport', 'city': 'Tokyo', 'country': 'Japan'},
    'HND': {'name': 'Tokyo Haneda Airport', 'city': 'Tokyo', 'country': 'Japan'},
    'ICN': {'name': 'Seoul Incheon Airport', 'city': 'Seoul', 'country': 'South Korea'},
    'SIN': {'name': 'Singapore Changi Airport', 'city': 'Singapore', 'country': 'Singapore'},
    'BKK': {'name': 'Bangkok Suvarnabhumi', 'city': 'Bangkok', 'country': 'Thailand'},
    'DEL': {'name': 'Delhi International Airport', 'city': 'Delhi', 'country': 'India'},
    'SYD': {'name': 'Sydney Airport', 'city': 'Sydney', 'country': 'Australia'},
    'YYZ': {'name': 'Toronto Pearson Airport', 'city': 'Toronto', 'country': 'Canada'},
    // Ethiopian domestic airports
    'DIR': {'name': 'Dire Dawa Airport', 'city': 'Dire Dawa', 'country': 'Ethiopia'},
    'MQX': {'name': 'Mekelle Airport', 'city': 'Mekelle', 'country': 'Ethiopia'},
    'BJR': {'name': 'Bahir Dar Airport', 'city': 'Bahir Dar', 'country': 'Ethiopia'},
    'GDQ': {'name': 'Gondar Airport', 'city': 'Gondar', 'country': 'Ethiopia'},
    'LLI': {'name': 'Lalibela Airport', 'city': 'Lalibela', 'country': 'Ethiopia'},
    'AXU': {'name': 'Axum Airport', 'city': 'Axum', 'country': 'Ethiopia'},
  };

  // Airline database
  static final Map<String, Map<String, String>> _airlineDatabase = {
    'ET': {'name': 'Ethiopian Airlines', 'country': 'Ethiopia', 'hub': 'ADD', 'ranking': 'Best African Airline'},
    'QR': {'name': 'Qatar Airways', 'country': 'Qatar', 'hub': 'DOH', 'ranking': '#1 World Best 2025'},
    'SQ': {'name': 'Singapore Airlines', 'country': 'Singapore', 'hub': 'SIN', 'ranking': '#2 World Best 2025'},
    'CX': {'name': 'Cathay Pacific', 'country': 'Hong Kong', 'hub': 'HKG', 'ranking': '#3 World Best 2025'},
    'EK': {'name': 'Emirates', 'country': 'UAE', 'hub': 'DXB', 'ranking': '#4 World Best 2025'},
    'NH': {'name': 'ANA All Nippon Airways', 'country': 'Japan', 'hub': 'HND', 'ranking': '#5 World Best 2025'},
    'TK': {'name': 'Turkish Airlines', 'country': 'Turkey', 'hub': 'IST', 'ranking': '#6 World Best 2025'},
    'KE': {'name': 'Korean Air', 'country': 'South Korea', 'hub': 'ICN', 'ranking': '#7 World Best 2025'},
    'AF': {'name': 'Air France', 'country': 'France', 'hub': 'CDG', 'ranking': '#8 World Best 2025'},
    'JL': {'name': 'Japan Airlines', 'country': 'Japan', 'hub': 'HND', 'ranking': '#9 World Best 2025'},
  };

  // Popular routes
  static final List<Map<String, dynamic>> _popularRoutes = [
    {'from': 'NYC', 'to': 'LAX', 'description': 'Transcontinental US route', 'bestPrice': '\$279', 'bestAirline': 'JetBlue'},
    {'from': 'LAX', 'to': 'DXB', 'description': 'Long-haul to Middle East', 'bestPrice': '\$590', 'bestAirline': 'Turkish'},
    {'from': 'DXB', 'to': 'ADD', 'description': 'Middle East to Africa', 'bestPrice': '\$390', 'bestAirline': 'Air Arabia'},
    {'from': 'ADD', 'to': 'NBO', 'description': 'East African regional', 'bestPrice': '\$220', 'bestAirline': 'Ethiopian'},
    {'from': 'JFK', 'to': 'LHR', 'description': 'Premium transatlantic', 'bestPrice': '\$650', 'bestAirline': 'British'},
  ];

  static String getResponse(String userMessage, List<ChatMessage> chatHistory) {
    final correctedMessage = _correctSpelling(userMessage.toLowerCase().trim());

    // Check for number inputs first
    if (_isNumberInput(correctedMessage)) {
      return _handleNumberInput(correctedMessage);
    }

    // If it's a greeting or first message, show the menu
    if (_isGreeting(correctedMessage) || chatHistory.length <= 1) {
      return _displayMainMenu();
    }

    // Airport code explanation
    if (_isAirportCodeQuery(correctedMessage)) {
      return _handleAirportCodeQuery(correctedMessage);
    }

    // Airline information
    if (_isAirlineQuery(correctedMessage)) {
      return _handleAirlineQuery(correctedMessage);
    }

    // Route suggestions
    if (_isRouteQuery(correctedMessage)) {
      return _handleRouteQuery(correctedMessage);
    }

    // Price comparisons
    if (_isPriceQuery(correctedMessage)) {
      return _handlePriceQuery(correctedMessage);
    }

    // Ethiopian Airlines specific
    if (_isEthiopianQuery(correctedMessage)) {
      return _handleEthiopianQuery(correctedMessage);
    }

    // Help or unclear queries
    if (_isHelpQuery(correctedMessage)) {
      return _displayMainMenu();
    }

    // Default response - show menu again
    return _handleUnknownQuery(correctedMessage);
  }

  static String _displayMainMenu() {
    return """🌟 **Flight Assistant AI** ✈️

**Quick Menu - Choose a number:**

1️⃣ **Airport Codes & Info**
   Find airport details and codes
   *Example: "What is DXB?"*

2️⃣ **Airlines Information**  
   Get airline details and rankings
   *Example: "Tell me about Ethiopian Airlines"*

3️⃣ **Flight Routes**
   Popular routes and suggestions
   *Example: "Flights from NYC to LAX"*

4️⃣ **Price Information**
   Flight prices and saving tips
   *Example: "How much NYC to LAX?"*

5️⃣ **Ethiopian Airlines**
   Ethiopian Airlines information
   *Example: "Ethiopian domestic flights"*

6️⃣ **Top Airlines 2025**
   World's best airlines ranking

7️⃣ **Popular Routes**
   Busiest flight routes

8️⃣ **Money Saving Tips**
   How to save on flights

9️⃣ **Ethiopian Domestic**
   Local flights in Ethiopia

0️⃣ **Show Menu Again**

💡 **Tip**: Type a number (0-9) or ask directly""";
  }

  static bool _isNumberInput(String message) {
    final numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    return numbers.contains(message) && message.length == 1;
  }

  static String _handleNumberInput(String number) {
    switch (number) {
      case '1':
        return _getAirportCodeMenu();
      case '2':
        return _getAirlinesMenu();
      case '3':
        return _getRoutesMenu();
      case '4':
        return _getPriceMenu();
      case '5':
        return _getEthiopianMenu();
      case '6':
        return _getTopAirlines();
      case '7':
        return _getPopularRoutes();
      case '8':
        return _getMoneySavingTips();
      case '9':
        return _getEthiopianDomestic();
      case '0':
        return _displayMainMenu();
      default:
        return _handleUnknownQuery(number);
    }
  }

  static String _getAirportCodeMenu() {
    return """🏢 **Airport Codes**

**Popular Airports:**
• **NYC** - New York City
• **LAX** - Los Angeles  
• **DXB** - Dubai
• **ADD** - Addis Ababa
• **LHR** - London
• **CDG** - Paris
• **JFK** - New York JFK
• **SIN** - Singapore
• **IST** - Istanbul
• **NRT** - Tokyo

💡 Ask about any airport code
Type **0** to return to main menu""";
  }

  static String _getAirlinesMenu() {
    return """✈️ **Airlines Information**

**Top Airlines:**
• **Qatar Airways** - World's Best
• **Singapore Airlines** - Best Crew
• **Ethiopian Airlines** - Best Africa
• **Emirates** - Best Entertainment
• **Turkish Airlines** - Best Business
• **Cathay Pacific** - Premium Service
• **ANA All Nippon** - Japanese
• **Qantas** - Best Australia
• **Lufthansa** - European
• **British Airways** - UK Flag

💡 Ask about any airline
Type **0** for main menu""";
  }

  static String _getRoutesMenu() {
    return """🛫 **Flight Routes**

**Popular Routes:**
• **NYC → LAX** - \$279
• **LAX → DXB** - \$590  
• **DXB → ADD** - \$390
• **ADD → NBO** - \$220
• **JFK → LHR** - \$650
• **ADD → LHR** - \$720
• **ADD → IST** - \$450
• **ADD → CDG** - \$690
• **DXB → LHR** - \$480
• **ADD → BKK** - \$580

💡 Ask about specific routes
Type **0** for main menu""";
  }

  static String _getPriceMenu() {
    return """💰 **Price Information**

**Price Ranges:**
• **Domestic US**: \$150-\$400
• **Domestic Ethiopia**: \$50-\$200  
• **Short International**: \$200-\$600
• **Medium International**: \$400-\$900
• **Long International**: \$600-\$1,500+

**Saving Tips:**
• Book 2-3 months in advance
• Be flexible with dates
• Consider red-eye flights
• Check budget airlines
• Use mobile deals

💡 Ask about specific routes
Type **0** for main menu""";
  }

  static String _getEthiopianMenu() {
    return """🇪🇹 **Ethiopian Airlines**

**International from ADD:**
• **Dubai (DXB)** - 4+ daily
• **London (LHR)** - Daily  
• **Washington (IAD)** - Daily
• **Istanbul (IST)** - 2 daily
• **Paris (CDG)** - Daily
• **Beijing (PEK)** - 5 weekly
• **Nairobi (NBO)** - 3 daily
• **Frankfurt (FRA)** - Daily
• **Bangkok (BKK)** - 4 weekly
• **Johannesburg (JNB)** - Daily

💡 Type **9** for domestic flights
Type **0** for main menu""";
  }

  static String _getTopAirlines() {
    return """🏆 **Top Airlines 2025**

1. **Qatar Airways** 🇶🇦
   World's Best Airline
   Hub: Doha (DOH)

2. **Singapore Airlines** 🇸🇬
   Best Cabin Crew
   Hub: Singapore (SIN)

3. **Cathay Pacific** 🇭🇰
   Best Business Class
   Hub: Hong Kong (HKG)

4. **Emirates** 🇦🇪
   Best Entertainment
   Hub: Dubai (DXB)

5. **Ethiopian Airlines** 🇪🇹
   Best African Airline
   Hub: Addis Ababa (ADD)

💡 Type **0** for main menu""";
  }

  static String _getPopularRoutes() {
    final response = StringBuffer();
    response.writeln("🌟 **Popular Routes**\n");

    for (int i = 0; i < _popularRoutes.length; i++) {
      final route = _popularRoutes[i];
      final fromCity = _airportDatabase[route['from']]?['city'] ?? route['from'];
      final toCity = _airportDatabase[route['to']]?['city'] ?? route['to'];
      response.writeln("• **$fromCity → $toCity**");
      response.writeln("  ${route['bestPrice']} | ${route['bestAirline']}");
      response.writeln("  ${route['description']}");
      if (i < _popularRoutes.length - 1) response.writeln("");
    }

    response.writeln("\n💡 Type **0** for main menu");
    return response.toString();
  }

  static String _getMoneySavingTips() {
    return """💸 **Money Saving Tips**

• **Book in Advance**
  International: 2-3 months
  Domestic: 3-6 weeks

• **Flexible Dates**
  Travel Tue-Thu
  Avoid weekends

• **Alternative Airports**
  NYC: JFK, LGA, EWR
  London: LHR, LGW

• **Red-Eye Flights**
  Overnight = cheaper
  Early morning = savings

• **Travel Light**
  Avoid baggage fees
  Pack carry-on only

💡 Type **0** for main menu""";
  }

  static String _getEthiopianDomestic() {
    final response = StringBuffer();
    response.writeln("🇪🇹 **Ethiopian Domestic**\n");

    response.writeln("**From Addis Ababa (ADD):**");
    final domesticAirports = ['DIR', 'MQX', 'BJR', 'GDQ', 'LLI', 'AXU'];
    for (final code in domesticAirports) {
      final airport = _airportDatabase[code]!;
      response.writeln("• **${airport['city']} ($code)**");
      response.writeln("  Multiple daily flights");
      response.writeln("  Average: \$50-\$150");
    }

    response.writeln("\n💡 Type **0** for main menu");
    return response.toString();
  }

  static String _handleUnknownQuery(String message) {
    return """❓ **Not sure what you need**

**Options - Type a number:**

1 Airport Codes & Info
2 Airlines Information  
3 Flight Routes
4 Price Information
5 Ethiopian Airlines
6 Top Airlines 2025
7 Popular Routes  
8 Money Saving Tips
9 Ethiopian Domestic
0 Show Main Menu

💡 Try a number or ask differently
*Example: "What is DXB?"*""";
  }

  static String _correctSpelling(String message) {
    String corrected = message;
    _spellingCorrections.forEach((wrong, correct) {
      if (corrected.contains(wrong)) {
        corrected = corrected.replaceAll(wrong, correct);
      }
    });
    return corrected;
  }

  static bool _isAirportCodeQuery(String message) {
    final codes = RegExp(r'[A-Z]{3}').allMatches(message.toUpperCase()).toList();
    if (codes.isNotEmpty) return true;
    final airportWords = ['airport', 'code', 'what is', 'mean', 'means', 'stand for'];
    return airportWords.any((word) => message.contains(word)) && message.length < 20;
  }

  static bool _isAirlineQuery(String message) {
    final airlines = ['airline', 'ethiopian', 'qatar', 'emirates', 'singapore', 'turkish', 'british', 'lufthansa', 'air france', 'qantas', 'american', 'delta', 'united'];
    return airlines.any((airline) => message.contains(airline));
  }

  static bool _isRouteQuery(String message) {
    return message.contains('route') || message.contains('fly from') || message.contains('to ') || message.contains('flight from') || message.contains('best flight') || message.contains('suggest') || message.contains('go from') || message.contains('travel from');
  }

  static bool _isPriceQuery(String message) {
    return message.contains('price') || message.contains('cheap') || message.contains('expensive') || message.contains('cost') || message.contains('how much') || message.contains('fare') || message.contains('money');
  }

  static bool _isEthiopianQuery(String message) {
    return message.contains('ethiopia') || message.contains('addis') || message.contains('bole') || message.contains('domestic') || message.contains('local flight') || message.contains('ethiopian');
  }

  static bool _isGreeting(String message) {
    return message.contains('hello') || message.contains('hi') || message.contains('hey') || message.contains('good morning') || message.contains('good afternoon') || message.contains('good evening') || message == '' || message.length < 3;
  }

  static bool _isHelpQuery(String message) {
    return message.contains('help') || message.contains('what can you do') || message.contains('how to use') || message.contains('support') || message.contains('assist');
  }

  static String _handleAirportCodeQuery(String message) {
    final codes = RegExp(r'[A-Z]{3}').allMatches(message.toUpperCase()).map((m) => m.group(0)!).toList();
    final response = StringBuffer();
    response.writeln("🏢 **Airport Information**\n");

    if (codes.isNotEmpty) {
      for (final code in codes.take(3)) {
        if (_airportDatabase.containsKey(code)) {
          final airport = _airportDatabase[code]!;
          response.writeln("**$code**");
          response.writeln("${airport['name']}");
          response.writeln("${airport['city']}, ${airport['country']}");
          response.writeln("");
        }
      }
      response.writeln("💡 Need more? Type **1** for Airport Menu");
    } else {
      response.writeln("💡 Type an airport code like 'DXB'");
    }
    return response.toString();
  }

  static String _handleAirlineQuery(String message) {
    final response = StringBuffer();
    response.writeln("✈️ **Airline Information**\n");

    final matchedAirlines = _airlineDatabase.entries.where((entry) {
      final airline = entry.value;
      return message.contains(airline['name']!.toLowerCase()) || message.contains(airline['country']!.toLowerCase());
    }).toList();

    if (matchedAirlines.isNotEmpty) {
      for (final entry in matchedAirlines.take(2)) {
        final airline = entry.value;
        response.writeln("**${airline['name']}**");
        response.writeln("HQ: ${airline['country']}");
        response.writeln("Hub: ${_airportDatabase[airline['hub']]?['name'] ?? airline['hub']}");
        response.writeln("Rank: ${airline['ranking']}");
        response.writeln("");
      }
      response.writeln("💡 Type **2** for Airlines Menu");
    } else {
      response.writeln("💡 Type **2** for Airlines Menu");
    }

    return response.toString();
  }

  static String _handleRouteQuery(String message) {
    return _getRoutesMenu();
  }

  static String _handlePriceQuery(String message) {
    return _getPriceMenu();
  }

  static String _handleEthiopianQuery(String message) {
    return _getEthiopianMenu();
  }
}