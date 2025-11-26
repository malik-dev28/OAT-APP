// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController(text: 'IAD');
  final _destinationController = TextEditingController(text: 'DXB');
  final _departureController = TextEditingController(text: '2025-11-20');
  final _returnController = TextEditingController(text: '2025-11-27');
  final _adultsController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Search'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: provider.clearData),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _originController,
                decoration: InputDecoration(
                  labelText: 'Origin Airport (IATA)',
                  hintText: 'e.g., IAD',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter origin airport';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination Airport (IATA)',
                  hintText: 'e.g., DXB',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination airport';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _departureController,
                decoration: InputDecoration(
                  labelText: 'Departure Date (YYYY-MM-DD)',
                  hintText: 'e.g., 2025-11-20',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter departure date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _returnController,
                decoration: InputDecoration(
                  labelText: 'Return Date (YYYY-MM-DD)',
                  hintText: 'e.g., 2025-11-27',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter return date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _adultsController,
                decoration: InputDecoration(labelText: 'Adults'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of adults';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              if (provider.isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await provider.searchFlights(
                        origin: _originController.text,
                        destination: _destinationController.text,
                        departureDate: _departureController.text,
                        returnDate: _returnController.text,
                        adults: int.parse(_adultsController.text),
                      );

                      if (provider.error == null &&
                          provider.flightOffers != null) {
                        Navigator.pushNamed(context, '/offers');
                      }
                    }
                  },
                  child: Text('Search Flights'),
                ),
              if (provider.error != null) ...[
                SizedBox(height: 16),
                Text(provider.error!, style: TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    _adultsController.dispose();
    super.dispose();
  }
}
