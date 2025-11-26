// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/app_provider.dart';
import 'pages/search_screen.dart';
import 'pages/offers_screen.dart';
import 'pages/offer_detail_screen.dart';
import 'pages/booking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      import 'package:flutter/material.dart';
      import 'package:provider/provider.dart';
      import 'package:flutter_dotenv/flutter_dotenv.dart';
      import 'providers/app_provider.dart';
      import 'pages/search_screen.dart';
      import 'pages/offers_screen.dart';
      import 'pages/offer_detail_screen.dart';
      import 'pages/booking_screen.dart';

      void main() async {
        WidgetsFlutterBinding.ensureInitialized();
        await dotenv.load(fileName: "assets/.env");
        runApp(MyApp());
      }

      class MyApp extends StatelessWidget {
        const MyApp({super.key});

        @override
        Widget build(BuildContext context) {
          return ChangeNotifierProvider(
            create: (context) => AppProvider(),
            child: MaterialApp(
              title: 'Amadeus Flight App',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: SearchScreen(),
              routes: {
                '/search': (context) => SearchScreen(),
                '/offers': (context) => OffersScreen(),
                '/offer-detail': (context) => OfferDetailScreen(),
                '/booking': (context) => BookingScreen(),
              },
            ),
          );
        }
      }

