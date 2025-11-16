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
    // ... (keep all your existing spelling corrections)
  };

  // Airport database
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
    // ... (keep all your existing airport database)
  };

  // Airline database
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
    // ... (keep all your existing airline database)
  };

  // Popular routes
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
    // ... (keep all your existing routes)
  ];

  static String getResponse(String userMessage, List<ChatMessage> chatHistory) {
    // First, correct any spelling mistakes
    final correctedMessage = _correctSpelling(userMessage.toLowerCase().trim());

    print("Original: $userMessage");
    print("Corrected: $correctedMessage");

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
    return """👋 **WELCOME TO FLIGHT ASSISTANT AI!** ✈️

**Please choose what you need help with:**

🔢 **QUICK MENU - TYPE A NUMBER:**

1️⃣ 🏢 **AIRPORT CODES & INFORMATION**
   - Find airport details and codes
   - Example: "What is DXB?" or "JFK airport info"

2️⃣ ✈️ **AIRLINES INFORMATION**  
   - Get airline details and rankings
   - Example: "Tell me about Ethiopian Airlines"

3️⃣ 🛫 **FLIGHT ROUTES & SUGGESTIONS**
   - Popular routes and recommendations
   - Example: "Flights from NYC to LAX"

4️⃣ 💰 **PRICE INFORMATION & TIPS**
   - Flight prices and money saving tips
   - Example: "How much NYC to LAX?"

5️⃣ 🇪🇹 **ETHIOPIAN AIRLINES & ROUTES**
   - Ethiopian Airlines information
   - Example: "Ethiopian domestic flights"

6️⃣ 🏆 **TOP 10 AIRLINES 2025**
   - World's best airlines ranking

7️⃣ 🌟 **MOST POPULAR ROUTES**
   - Busiest flight routes worldwide

8️⃣ 💸 **MONEY SAVING TIPS**
   - How to save money on flights

9️⃣ 🗺️ **ETHIOPIAN DOMESTIC FLIGHTS**
   - Local flights within Ethiopia

0️⃣ 🔄 **SHOW THIS MENU AGAIN**

**💡 TIP: Type a number (0-9) or ask your question directly!**

*Example: Type "1" for airport codes or just ask "What is DXB airport?"*""";
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
    return """🏢 **AIRPORT CODES MENU** ✈️

**Popular Airport Codes:**

1️⃣ **NYC** - New York City (Multiple airports)
2️⃣ **LAX** - Los Angeles International Airport  
3️⃣ **DXB** - Dubai International Airport
4️⃣ **ADD** - Addis Ababa Bole Airport
5️⃣ **LHR** - London Heathrow Airport
6️⃣ **CDG** - Paris Charles de Gaulle
7️⃣ **JFK** - New York JFK Airport
8️⃣ **SIN** - Singapore Changi Airport
9️⃣ **IST** - Istanbul Airport
🔟 **NRT** - Tokyo Narita Airport

**💡 How to use:**
- Type an airport code like "DXB" or "ADD"
- Ask "What is LAX airport?"
- Or type **0** to return to main menu

**Ask me about any airport code!**""";
  }

  static String _getAirlinesMenu() {
    return """✈️ **AIRLINES INFORMATION MENU** 🏆

**Top Airlines 2025:**

1️⃣ **Qatar Airways** - World's Best Airline
2️⃣ **Singapore Airlines** - Best Cabin Crew
3️⃣ **Ethiopian Airlines** - Best African Airline
4️⃣ **Emirates** - Best Inflight Entertainment
5️⃣ **Turkish Airlines** - Best Business Class
6️⃣ **Cathay Pacific** - Premium Service
7️⃣ **ANA All Nippon** - Japanese Excellence
8️⃣ **Qantas** - Best Australian Airline
9️⃣ **Lufthansa** - European Leader
🔟 **British Airways** - UK Flag Carrier

**💡 How to use:**
- Ask "Tell me about Ethiopian Airlines"
- Type "Qatar Airways info"
- Or type **0** to return to main menu

**Ask about any airline!**""";
  }

  static String _getRoutesMenu() {
    return """🛫 **FLIGHT ROUTES MENU** 🌍

**Popular Flight Routes:**

1️⃣ **NYC → LAX** - US Transcontinental (\$279)
2️⃣ **LAX → DXB** - US to Middle East (\$590)  
3️⃣ **DXB → ADD** - Dubai to Addis (\$390)
4️⃣ **ADD → NBO** - East Africa Regional (\$220)
5️⃣ **JFK → LHR** - Transatlantic Premium (\$650)
6️⃣ **ADD → LHR** - Africa to Europe (\$720)
7️⃣ **ADD → IST** - Africa to Turkey (\$450)
8️⃣ **ADD → CDG** - Africa to Paris (\$690)
9️⃣ **DXB → LHR** - Middle East to Europe (\$480)
🔟 **ADD → BKK** - Africa to Asia (\$580)

**💡 How to use:**
- Ask "Flights from NYC to LAX"
- Type "Routes from Addis Ababa"
- Or type **0** to return to main menu

**Ask about any route!**""";
  }

  static String _getPriceMenu() {
    return """💰 **PRICE INFORMATION MENU** 💸

**Typical Price Ranges:**

1️⃣ **Domestic US Flights**: \$150 - \$400
2️⃣ **Domestic Ethiopia**: \$50 - \$200  
3️⃣ **Short International (3-6h)**: \$200 - \$600
4️⃣ **Medium International (6-12h)**: \$400 - \$900
5️⃣ **Long International (12h+)**: \$600 - \$1,500+

**Money Saving Tips:**
6️⃣ **Book Early** - 2-3 months in advance
7️⃣ **Flexible Dates** - +/- 3 days search
8️⃣ **Red-Eye Flights** - Overnight savings
9️⃣ **Budget Airlines** - Low-cost options
🔟 **Mobile Deals** - App exclusives

**💡 How to use:**
- Ask "Price of NYC to LAX"
- Type "Cheapest time to fly to Dubai"
- Or type **0** to return to main menu

**Ask about specific routes!**""";
  }

  static String _getEthiopianMenu() {
    return """🇪🇹 **ETHIOPIAN AIRLINES MENU** ✈️

**International Routes from ADD:**

1️⃣ **Dubai (DXB)** - 4+ daily flights
2️⃣ **London (LHR)** - Daily flights  
3️⃣ **Washington (IAD)** - Daily flights
4️⃣ **Istanbul (IST)** - 2 daily flights
5️⃣ **Paris (CDG)** - Daily flights
6️⃣ **Beijing (PEK)** - 5 weekly flights
7️⃣ **Nairobi (NBO)** - 3 daily flights
8️⃣ **Frankfurt (FRA)** - Daily flights
9️⃣ **Bangkok (BKK)** - 4 weekly flights
🔟 **Johannesburg (JNB)** - Daily flights

**💡 How to use:**
- Ask "Ethiopian Airlines domestic flights"
- Type "Flights from ADD to DXB"
- Type **9** for domestic flights
- Or type **0** for main menu

**Ask about Ethiopian Airlines!**""";
  }

  static String _getTopAirlines() {
    return """🏆 **TOP 10 AIRLINES 2025** 🌟

1️⃣ **Qatar Airways** 🇶🇦
   🏅 World's Best Airline 2025
   ✈️ Hub: Doha (DOH)
   ⭐ Best for: Overall Experience

2️⃣ **Singapore Airlines** 🇸🇬
   🏅 Best Cabin Crew
   ✈️ Hub: Singapore (SIN)  
   ⭐ Best for: Service Quality

3️⃣ **Cathay Pacific** 🇭🇰
   🏅 Best Business Class
   ✈️ Hub: Hong Kong (HKG)
   ⭐ Best for: Premium Cabins

4️⃣ **Emirates** 🇦🇪
   🏅 Best Inflight Entertainment
   ✈️ Hub: Dubai (DXB)
   ⭐ Best for: Entertainment

5️⃣ **Ethiopian Airlines** 🇪🇹
   🏅 Best African Airline
   ✈️ Hub: Addis Ababa (ADD)
   ⭐ Best for: African Routes

**💡 Type 0 to return to main menu**""";
  }

  static String _getPopularRoutes() {
    final response = StringBuffer();
    response.writeln("🌟 **MOST POPULAR FLIGHT ROUTES** 🛫\n");

    for (int i = 0; i < _popularRoutes.length; i++) {
      final route = _popularRoutes[i];
      final fromCity =
          _airportDatabase[route['from']]?['city'] ?? route['from'];
      final toCity = _airportDatabase[route['to']]?['city'] ?? route['to'];
      response.writeln("${i + 1}️⃣ **$fromCity → $toCity**");
      response
          .writeln("   💰 ${route['bestPrice']} | ✈️ ${route['bestAirline']}");
      response.writeln("   📝 ${route['description']}");
      if (i < _popularRoutes.length - 1) response.writeln("");
    }

    response.writeln("\n**💡 Type 0 to return to main menu**");
    return response.toString();
  }

  static String _getMoneySavingTips() {
    return """💸 **MONEY SAVING TIPS FOR FLIGHTS** 💰

1️⃣ **Book in Advance** 📅
   • International: 2-3 months before
   • Domestic: 3-6 weeks before  
   • Last-minute deals are rare!

2️⃣ **Be Flexible with Dates** 🔄
   • Travel Tuesday-Thursday
   • Avoid weekends and holidays
   • Use +/- 3 days search

3️⃣ **Consider Alternative Airports** 🏢
   • NYC: JFK, LGA, EWR
   • London: LHR, LGW, STN
   • Tokyo: NRT, HND

4️⃣ **Fly Red-Eye or Early Morning** 🌙
   • Overnight flights are cheaper
   • Early morning departures save money
   • Less popular times = better prices

5️⃣ **Travel Light** 🎒
   • Avoid baggage fees
   • Pack carry-on only
   • Check airline baggage policies

**💡 Type 0 to return to main menu**
*Happy travels and smart savings!* ✈️""";
  }

  static String _getEthiopianDomestic() {
    final response = StringBuffer();
    response.writeln("🇪🇹 **ETHIOPIAN DOMESTIC FLIGHTS** 🗺️\n");

    response.writeln("**From Addis Ababa (ADD) to:**");
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
    for (int i = 0; i < domesticAirports.length; i++) {
      final code = domesticAirports[i];
      final airport = _airportDatabase[code]!;
      response.writeln("${i + 1}️⃣ **${airport['city']} ($code)**");
      response.writeln("   ✈️ Multiple daily flights");
      response.writeln("   💰 Average price: \$50-\$150");
      if (i < domesticAirports.length - 1) response.writeln("");
    }

    response.writeln("\n**💡 Type 0 to return to main menu**");
    return response.toString();
  }

  static String _handleUnknownQuery(String message) {
    return """❓ **I'm not sure what you need**

It looks like I didn't understand your question. 

**Here are your options:**

🔢 **QUICK MENU - TYPE A NUMBER:**

1️⃣ Airport Codes & Information
2️⃣ Airlines Information  
3️⃣ Flight Routes & Suggestions
4️⃣ Price Information & Tips
5️⃣ Ethiopian Airlines & Routes
6️⃣ Top 10 Airlines 2025
7️⃣ Most Popular Routes  
8️⃣ Money Saving Tips
9️⃣ Ethiopian Domestic Flights
0️⃣ Show Main Menu

**💡 Try typing a number 0-9 or ask your question differently!**

*Example: "What is DXB?" or "Tell me about Ethiopian Airlines"*""";
  }

  // Keep all your existing helper methods (they remain the same)
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
    final codes =
        RegExp(r'[A-Z]{3}').allMatches(message.toUpperCase()).toList();
    if (codes.isNotEmpty) return true;
    final airportWords = [
      'airport',
      'code',
      'what is',
      'mean',
      'means',
      'stand for'
    ];
    return airportWords.any((word) => message.contains(word)) &&
        message.length < 20;
  }

  static bool _isAirlineQuery(String message) {
    final airlines = [
      'airline',
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
        message.contains('flight from') ||
        message.contains('best flight') ||
        message.contains('suggest') ||
        message.contains('go from') ||
        message.contains('travel from');
  }

  static bool _isPriceQuery(String message) {
    return message.contains('price') ||
        message.contains('cheap') ||
        message.contains('expensive') ||
        message.contains('cost') ||
        message.contains('how much') ||
        message.contains('fare') ||
        message.contains('money');
  }

  static bool _isEthiopianQuery(String message) {
    return message.contains('ethiopia') ||
        message.contains('addis') ||
        message.contains('bole') ||
        message.contains('domestic') ||
        message.contains('local flight') ||
        message.contains('ethiopian');
  }

  static bool _isGreeting(String message) {
    return message.contains('hello') ||
        message.contains('hi') ||
        message.contains('hey') ||
        message.contains('good morning') ||
        message.contains('good afternoon') ||
        message.contains('good evening') ||
        message == '' ||
        message.length < 3;
  }

  static bool _isHelpQuery(String message) {
    return message.contains('help') ||
        message.contains('what can you do') ||
        message.contains('how to use') ||
        message.contains('support') ||
        message.contains('assist');
  }

  // Keep your existing detailed query handlers
  static String _handleAirportCodeQuery(String message) {
    final codes = RegExp(r'[A-Z]{3}')
        .allMatches(message.toUpperCase())
        .map((m) => m.group(0)!)
        .toList();
    final response = StringBuffer();
    response.writeln("🏢 **Airport Information** ✈️\n");

    if (codes.isNotEmpty) {
      for (final code in codes.take(3)) {
        if (_airportDatabase.containsKey(code)) {
          final airport = _airportDatabase[code]!;
          response.writeln("**$code**: ${airport['name']}");
          response.writeln("📍 ${airport['city']}, ${airport['country']}");
          response.writeln("");
        }
      }
      response.writeln(
          "💡 *Need more? Type 1 for Airport Codes Menu or 0 for Main Menu*");
    } else {
      response.writeln(
          "💡 *Type an airport code like 'DXB' or type 1 for Airport Codes Menu*");
    }
    return response.toString();
  }

  static String _handleAirlineQuery(String message) {
    final response = StringBuffer();
    response.writeln("✈️ **Airline Information** 🏆\n");

    // Find matching airlines and show info
    final matchedAirlines = _airlineDatabase.entries.where((entry) {
      final airline = entry.value;
      return message.contains(airline['name']!.toLowerCase()) ||
          message.contains(airline['country']!.toLowerCase());
    }).toList();

    if (matchedAirlines.isNotEmpty) {
      for (final entry in matchedAirlines.take(2)) {
        final airline = entry.value;
        response.writeln("**${airline['name']}** (${entry.key})");
        response.writeln("🇺🇳 **Headquarters**: ${airline['country']}");
        response.writeln(
            "🏠 **Main Hub**: ${_airportDatabase[airline['hub']]?['name'] ?? airline['hub']}");
        response.writeln("🏆 **Ranking**: ${airline['ranking']}");
        response.writeln("");
      }
      response.writeln("💡 *Type 2 for Airlines Menu or 0 for Main Menu*");
    } else {
      response.writeln(
          "💡 *Type 2 for Airlines Menu or ask about a specific airline*");
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
