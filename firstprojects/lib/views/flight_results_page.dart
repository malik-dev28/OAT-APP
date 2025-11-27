import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/flight_offer.dart';
import '../utils/app_routes.dart';

class FlightResultsPage extends StatelessWidget {
  final List<FlightOffer> offers;

  const FlightResultsPage({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasOffers = offers.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Flight Results'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_rounded, color: colorScheme.primary),
            onPressed: () => Get.toNamed(AppRoutes.chatbot),
          ),
        ],
      ),
      body: hasOffers
          ? _buildOffersList(textTheme, colorScheme)
          : _buildEmptyState(),
      floatingActionButton: hasOffers
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(AppRoutes.booking),
              icon: Icon(Icons.local_activity, color: colorScheme.onPrimary),
              label: const Text('Book Flight'),
              backgroundColor: colorScheme.primary,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildOffersList(TextTheme textTheme, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final itinerary = offer.itineraries.isNotEmpty
            ? offer.itineraries.first
            : null;
        final segments = itinerary?.segments ?? [];
        if (segments.isEmpty) return const SizedBox.shrink();

        final firstSegment = segments.first;
        final lastSegment = segments.last;
        final departureTime =
            DateTime.tryParse(firstSegment.departure.at ?? '') ??
            DateTime.now();
        final arrivalTime =
            DateTime.tryParse(lastSegment.arrival.at ?? '') ?? DateTime.now();
        final duration = arrivalTime.difference(departureTime);
        final stopsText = _getStopsText(segments.length);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black.withOpacity(0.1),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Get.toNamed(AppRoutes.booking),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offer.carrierName ??
                                    firstSegment.carrierCode ??
                                    'Unknown Airline',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(firstSegment.departure.at),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: stopsText == 'Direct'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            stopsText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: stopsText == 'Direct'
                                  ? Colors.green[400]
                                  : Colors.orange[300],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDateTime(firstSegment.departure.at),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                firstSegment.departure.iataCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.flight_takeoff,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 2,
                              width: 60,
                              color: segments.length > 1
                                  ? Colors.orange
                                  : colorScheme.primary,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDateTime(lastSegment.arrival.at),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                lastSegment.arrival.iataCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${segments.length} segment${segments.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${offer.numberOfBookableSeats} seats left',
                              style: TextStyle(
                                color: offer.numberOfBookableSeats < 5
                                    ? Colors.red
                                    : Colors.grey[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatPrice(
                            offer.totalPrice,
                            offer.currencyCode,
                            offer.currencyName,
                          ),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No flights found',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  String _formatDate(String? at) {
    if (at == null || at.isEmpty) return 'TBD';
    final parsed = DateTime.tryParse(at);
    if (parsed != null) return DateFormat('yyyy-MM-dd').format(parsed);
    return at.length >= 10 ? at.substring(0, 10) : 'TBD';
  }

  String _formatDateTime(String? at) {
    if (at == null || at.isEmpty) return 'TBD';
    final parsed = DateTime.tryParse(at);
    if (parsed != null) return DateFormat('HH:mm').format(parsed);
    return at.length >= 16 ? at.substring(11, 16) : at;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes.toString().padLeft(2, '0')} m';
    }
    return '$minutes min';
  }

  String _formatPrice(
    String? amount,
    String? currencyCode,
    String? currencyName,
  ) {
    if (amount == null || amount.isEmpty) return 'TBD';
    final code = currencyCode != null && currencyCode.isNotEmpty
        ? ' $currencyCode'
        : '';
    return '$amount$code';
  }

  String _getStopsText(int segments) {
    if (segments <= 1) return 'Direct';
    final stops = segments - 1;
    return '$stops stop${stops > 1 ? 's' : ''}';
  }
}
