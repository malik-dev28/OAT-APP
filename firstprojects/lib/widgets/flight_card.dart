import 'package:flutter/material.dart';

class FlightCard extends StatefulWidget {
  final Map flight;
  final int passengers;
  final VoidCallback? onFavorite;

  const FlightCard({
    super.key,
    required this.flight,
    this.passengers = 1,
    this.onFavorite,
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
  bool isFav = false;

  Widget carrierIcon(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 60, // Increased from 48
        height: 60, // Increased from 48
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade100, width: 1),
        ),
        child: Icon(Icons.flight_takeoff, size: 28, color: Colors.blue.shade600), // Increased from 24
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 60, // Increased from 48
        height: 60, // Increased from 48
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60, // Increased from 48
          height: 60, // Increased from 48
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.blue.shade100],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.flight_takeoff, size: 28, color: Colors.blue.shade600), // Increased from 24
        ),
      ),
    );
  }

  Widget _buildFlightRoute() {
    final time = widget.flight['time'] ?? '06:00';
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                widget.flight['from'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Departure',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Icon(Icons.flight, color: Colors.blue.shade600, size: 20),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                widget.flight['to'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Arrival',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final price = widget.flight['price'] ?? 0;
    final priceValue = price is String ? double.tryParse(price.replaceAll('\$', '')) ?? 0 : price.toDouble();
    final totalPrice = priceValue * widget.passengers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.passengers > 1) ...[
          Text(
            '\$$priceValue per person',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          '\$$totalPrice',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        if (widget.passengers > 1) ...[
          const SizedBox(height: 2),
          Text(
            'for ${widget.passengers} passenger${widget.passengers > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrier = widget.flight['carrier'] ?? 'Carrier';
    final code = widget.flight['carrierCode'] ?? '';
    final date = widget.flight['date'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with airline info and favorite
            Row(
              children: [
                carrierIcon(widget.flight['carrierLogo']),
                const SizedBox(width: 16), // Increased spacing to match larger image
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carrier,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        code.isNotEmpty ? 'Flight $code' : 'Flight',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPriceSection(),
              ],
            ),

            // Flight route visualization
            _buildFlightRoute(),

            // Footer with actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.shade100, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.airline_seat_recline_normal, 
                          size: 14, color: Colors.blue.shade600),
                      const SizedBox(width: 6),
                      Text(
                        "Economy",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Favorite button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey.shade400,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() => isFav = !isFav);
                      if (widget.onFavorite != null) widget.onFavorite!();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Book button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade500, Colors.blue.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // Handle book action
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          "Book",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}