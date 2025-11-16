import 'package:flutter/material.dart';
import 'package:flight_availability_app/screens/search_screen.dart';

void main() {
  runApp(const FlightAvailabilityApp());
}

class FlightAvailabilityApp extends StatelessWidget {
  const FlightAvailabilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Availability',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFFFF6D00),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
