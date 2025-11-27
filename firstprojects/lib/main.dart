// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/flight_offer.dart';
import 'views/main_home_page.dart';
import 'views/flight_booking_page.dart';
import 'views/flight_results_page.dart';
import 'views/chatbot_page.dart';
import 'utils/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _lightScheme = ColorScheme.fromSeed(
    seedColor: Colors.lightBlue,
    brightness: Brightness.light,
  );
  static final _darkScheme = ColorScheme.fromSeed(
    seedColor: Colors.blueGrey,
    brightness: Brightness.dark,
  );

  ThemeData _buildBaseTheme(ColorScheme scheme) {
    return ThemeData.from(colorScheme: scheme, useMaterial3: true).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surfaceVariant,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withOpacity(0.7),
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 28),
        unselectedIconTheme: IconThemeData(
          color: scheme.onSurface.withOpacity(0.65),
          size: 24,
        ),
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceVariant,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flight Assistant',
      debugShowCheckedModeBanner: false,
      theme: _buildBaseTheme(_lightScheme),
      darkTheme: _buildBaseTheme(_darkScheme),
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.home,
      getPages: [
        GetPage(name: AppRoutes.home, page: () => const MainHomePage()),
        GetPage(
          name: AppRoutes.flightResults,
          page: () {
            final args = Get.arguments;
            final offers = args is List<FlightOffer>
                ? args
                : const <FlightOffer>[];
            return FlightResultsPage(offers: offers);
          },
        ),
        GetPage(name: AppRoutes.booking, page: () => const FlightBookingPage()),
        GetPage(name: AppRoutes.chatbot, page: () => const ChatbotScreen()),
      ],
    );
  }
}
