// lib/screens/offer_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class OfferDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final offer = provider.selectedOffer;
    final priceDetails = provider.offerPrice;

    if (offer == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Offer Details')),
        body: Center(child: Text('No offer selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Offer Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total: ${offer['price']['total']} ${offer['price']['currency']}',
                    ),
                    Text(
                      'Base: ${offer['price']['base']} ${offer['price']['currency']}',
                    ),
                    if (priceDetails != null) ...[
                      SizedBox(height: 16),
                      Text(
                        'Detailed Pricing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ..._buildTaxesList(priceDetails),
                    ],
                  ],
                ),
              ),
            ),

            // Flight Itineraries
            ..._buildItineraries(offer),

            // Book Button
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/booking');
                },
                child: Text('Book This Flight'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItineraries(Map<String, dynamic> offer) {
    List<Widget> widgets = [];

    for (int i = 0; i < offer['itineraries'].length; i++) {
      final itinerary = offer['itineraries'][i];
      widgets.addAll([
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i == 0 ? 'Outbound Flight' : 'Return Flight',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Duration: ${itinerary['duration']}'),
                ..._buildSegments(itinerary['segments']),
              ],
            ),
          ),
        ),
      ]);
    }

    return widgets;
  }

  List<Widget> _buildSegments(List<dynamic> segments) {
    return segments.map<Widget>((segment) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${segment['departure']['iataCode']} → ${segment['arrival']['iataCode']}',
            ),
            Text('${segment['carrierCode']} ${segment['number']}'),
            Text('Depart: ${segment['departure']['at']}'),
            Text('Arrive: ${segment['arrival']['at']}'),
            Text('Duration: ${segment['duration']}'),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildTaxesList(Map<String, dynamic> priceDetails) {
    final travelerPricing =
        priceDetails['data']['flightOffers'][0]['travelerPricings'][0];
    final taxes = travelerPricing['price']['taxes'] ?? [];

    return taxes.map<Widget>((tax) {
      return Text('${tax['code']}: ${tax['amount']}');
    }).toList();
  }
}
