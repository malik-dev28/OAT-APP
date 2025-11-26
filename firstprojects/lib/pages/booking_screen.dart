// lib/screens/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Mr');
  final _lastNameController = TextEditingController(text: 'Beyene');
  final _emailController = TextEditingController(
    text: 'yonasbeyene12@gmail.com',
  );
  final _phoneController = TextEditingController(text: '27962417600');
  final _dobController = TextEditingController(text: '1998-05-03');

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Book Flight')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth (YYYY-MM-DD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (provider.isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final travelerData = {
                        'id': '1',
                        'dateOfBirth': _dobController.text,
                        'gender': 'MALE',
                        'name': {
                          'firstName': _firstNameController.text,
                          'lastName': _lastNameController.text,
                          'middleName': '',
                        },
                        'contact': {
                          'emailAddress': _emailController.text,
                          'phones': [
                            {
                              'deviceType': 'MOBILE',
                              'countryCallingCode': '27',
                              'number': _phoneController.text,
                            },
                          ],
                        },
                      };

                      await provider.createFlightOrder(travelerData);

                      if (provider.error == null &&
                          provider.createdOrder != null) {
                        _showSuccessDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking failed: ${provider.error}'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Confirm Booking'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Successful!'),
        content: Text('Your flight has been booked successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
