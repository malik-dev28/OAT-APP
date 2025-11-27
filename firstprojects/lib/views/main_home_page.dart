// lib/views/main_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'flight_search_page.dart';
import 'chatbot_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FlightSearchPage(), // Page 0
    const Center(
      child: Text('Favorites', style: TextStyle(fontSize: 20)),
    ), // Placeholder
    const Center(
      child: Text('Trips', style: TextStyle(fontSize: 20)),
    ), // Placeholder
    const Center(
      child: Text('Profile', style: TextStyle(fontSize: 20)),
    ), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Beautiful Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_takeoff),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),

      // Floating Chatbot Button (Always Visible)
      floatingActionButton: FloatingActionButton(
        heroTag: "chatbot_fab",
        backgroundColor: colorScheme.primary,
        elevation: 8,
        child: Icon(
          Icons.smart_toy_outlined,
          size: 28,
          color: colorScheme.onPrimary,
        ),
        onPressed: () {
          Get.to(
            () => const ChatbotScreen(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 400),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
