import 'package:flutter/material.dart';
import 'package:flight_availability_app/models/flight.dart';
import 'package:flight_availability_app/services/flight_service.dart';
import 'package:intl/intl.dart';

class ResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final String date;

  const ResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.date,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<Flight>> _flightsFuture;
  List<Flight> _allFlights = [];
  List<Flight> _filteredFlights = [];
  String _sortBy = 'price';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _flightsFuture = _loadFlights();
  }

  Future<List<Flight>> _loadFlights() async {
    try {
      final flights = await FlightService.searchFlights(
        origin: widget.origin,
        destination: widget.destination,
        date: widget.date,
      );

      setState(() {
        _allFlights = flights;
        _filteredFlights = flights;
        _isLoading = false;
      });

      _sortFlights(_sortBy);
      return flights;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  void _sortFlights(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      switch (sortBy) {
        case 'price':
          _filteredFlights.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'time':
          _filteredFlights.sort((a, b) => a.time.compareTo(b.time));
          break;
        case 'airline':
          _filteredFlights.sort((a, b) => a.carrier.compareTo(b.carrier));
          break;
      }
    });
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('EEE, MMM d, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget _buildFlightCard(Flight flight) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header with Airline and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Airline Info
                  Row(
                    children: [
                      // Airline Logo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(flight.carrierLogo),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.carrier,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            flight.flightNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      flight.formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Flight Route and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Departure
                  Column(
                    children: [
                      Text(
                        flight.from,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flight.time,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Departure',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Plane Icon
                  Column(
                    children: [
                      Icon(
                        Icons.airplanemode_active_rounded,
                        color: Colors.orange[500],
                        size: 24,
                      ),
                      Container(
                        height: 1,
                        width: 60,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      Text(
                        'Non-stop',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Arrival
                  Column(
                    children: [
                      Text(
                        flight.to,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calculateArrivalTime(flight.time),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Arrival',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showBookingDialog(flight);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1976D2),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(0xFF1976D2).withOpacity(0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Select Flight',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateArrivalTime(String departureTime) {
    try {
      final timeParts = departureTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Assume flight duration is 3 hours for domestic, 8 hours for international
      final isDomestic =
          widget.origin.length == 3 && widget.destination.length == 3;
      final durationHours = isDomestic ? 3 : 8;

      var arrivalHour = hour + durationHours;
      if (arrivalHour >= 24) {
        arrivalHour -= 24;
      }

      return '${arrivalHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  void _showBookingDialog(Flight flight) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flight Selected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${flight.from} → ${flight.to}'),
            Text('${flight.carrier} - ${flight.flightNumber}'),
            Text('Departure: ${flight.time}'),
            Text('Price: ${flight.formattedPrice}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking confirmed for ${flight.flightNumber}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      onSelected: _sortFlights,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'price',
          child: Row(
            children: [
              Icon(Icons.attach_money_rounded, size: 20),
              SizedBox(width: 8),
              Text('Sort by Price'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'time',
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 20),
              SizedBox(width: 8),
              Text('Sort by Time'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'airline',
          child: Row(
            children: [
              Icon(Icons.airline_seat_recline_extra_rounded, size: 20),
              SizedBox(width: 8),
              Text('Sort by Airline'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_rounded, size: 20),
            const SizedBox(width: 4),
            Text(
              'Sort: ${_sortBy == 'price' ? 'Price' : _sortBy == 'time' ? 'Time' : 'Airline'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Available Flights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [_buildSortButton()],
      ),
      body: FutureBuilder<List<Flight>>(
        future: _flightsFuture,
        builder: (context, snapshot) {
          if (_isLoading) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (_filteredFlights.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Header Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.origin} → ${widget.destination}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(widget.date),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_filteredFlights.length} flights found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Flights List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadFlights,
                  child: ListView.builder(
                    itemCount: _filteredFlights.length,
                    itemBuilder: (context, index) {
                      return _buildFlightCard(_filteredFlights[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
          ),
          const SizedBox(height: 20),
          Text(
            'Searching for flights...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.origin} → ${widget.destination}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 20),
            const Text(
              'No Flights Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sorry, we couldn\'t find any flights for your search.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _flightsFuture = _loadFlights();
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airplanemode_inactive_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'No Flights Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any flights matching your search criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('New Search'),
            ),
          ],
        ),
      ),
    );
  }
}
