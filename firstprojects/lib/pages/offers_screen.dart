// lib/screens/offers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class OffersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final offers = provider.flightOffers?['data'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Flight Offers (${offers.length})')),
      body: offers.isEmpty
          ? Center(child: Text('No flights found'))
          : ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                final firstItinerary = offer['itineraries'][0];
                final secondItinerary = offer['itineraries'][1];
                final price = offer['price'];

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      '${offer['validatingAirlineCodes'][0]} - ${price['total']} ${price['currency']}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outbound: ${firstItinerary['segments'][0]['departure']['iataCode']} → ${firstItinerary['segments'].last['arrival']['iataCode']}',
                        ),
                        Text(
                          'Return: ${secondItinerary['segments'][0]['departure']['iataCode']} → ${secondItinerary['segments'].last['arrival']['iataCode']}',
                        ),
                        Text(
                          'Duration: ${firstItinerary['duration']} / ${secondItinerary['duration']}',
                        ),
                        Text('Seats: ${offer['numberOfBookableSeats']}'),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      provider.getOfferPriceDetails(offer);
                      Navigator.pushNamed(context, '/offer-detail');
                    },
                  ),
                );
              },
            ),
    );
  }
}
