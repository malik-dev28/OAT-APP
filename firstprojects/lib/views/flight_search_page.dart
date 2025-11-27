// filepath: lib/views/flight_search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import '../models/flight_search_request.dart';
import '../repositories/auth_repository.dart';
import '../repositories/flight_repository.dart';
import '../utils/app_routes.dart';

class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key});

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _dep1Controller = TextEditingController(text: 'ADD');
  final _arr1Controller = TextEditingController(text: 'DXB');
  final _dep2Controller = TextEditingController(text: 'DXB');
  final _arr2Controller = TextEditingController(text: 'ADD');

  DateTime? _date1;
  DateTime? _date2;
  bool _isOneWay = false;

  int _adt = 1, _chd = 0, _inf = 0;
  bool _loading = false;
  String? _statusMessage;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final AuthRepository _authRepo = const HttpAuthRepository();
  final FlightRepository _flightRepo = const HttpFlightRepository();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _swapAirports() {
    final tempDep = _dep1Controller.text;
    final tempArr = _arr1Controller.text;
    setState(() {
      _dep1Controller.text = tempArr;
      _arr1Controller.text = tempDep;
      if (!_isOneWay) {
        _dep2Controller.text = tempArr;
        _arr2Controller.text = tempDep;
      }
    });
  }

  void _showTravellerPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TravellerPicker(
        adt: _adt,
        chd: _chd,
        inf: _inf,
        onChanged: (a, c, i) => setState(() {
          _adt = a;
          _chd = c;
          _inf = i;
        }),
      ),
    );
  }

  Future<void> _performSearch() async {
    // ... (same logic as before, just cleaner status updates)
    if (_date1 == null || (!_isOneWay && _date2 == null)) {
      Get.snackbar('Missing Date', 'Please select travel date(s)');
      return;
    }

    setState(() => _loading = true);
    _updateStatus('Authenticating...');

    try {
      final loginResp = await _authRepo.login().timeout(
        const Duration(seconds: 20),
      );
      _updateStatus('Verifying OTP...');
      final otpResp = await _authRepo.verifyOtp().timeout(
        const Duration(seconds: 20),
      );
      final token = otpResp['accessToken'] as String?;

      if (token == null) throw Exception('Authentication failed');

      _updateStatus('Searching best flights...');

      final req = FlightSearchRequest(
        originDestinations: [
          OriginDestination(
            departure: FlightPoint(
              airportCode: _dep1Controller.text.trim().toUpperCase(),
              date: DateFormat('yyyy-MM-dd').format(_date1!),
            ),
            arrival: FlightPoint(
              airportCode: _arr1Controller.text.trim().toUpperCase(),
            ),
          ),
          if (!_isOneWay)
            OriginDestination(
              departure: FlightPoint(
                airportCode: _dep2Controller.text.trim().toUpperCase(),
                date: DateFormat('yyyy-MM-dd').format(_date2!),
              ),
              arrival: FlightPoint(
                airportCode: _arr2Controller.text.trim().toUpperCase(),
              ),
            ),
        ],
        travellers: Travellers(adt: _adt, chd: _chd, inf: _inf),
      );

      final result = await _flightRepo
          .searchFlights(req, token)
          .timeout(const Duration(seconds: 30));
      final offers = ApiService.parseFlightOffers(result);

      if (!mounted) return;
      if (offers.isNotEmpty) {
        Get.toNamed(AppRoutes.flightResults, arguments: offers);
      } else {
        Get.snackbar('No flights', 'Try different dates or routes');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateStatus(String msg) {
    setState(() => _statusMessage = msg);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Search Flights'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Trip Type Switch
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Round Trip'),
                            icon: Icon(Icons.flight_takeoff),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('One Way'),
                            icon: Icon(Icons.flight),
                          ),
                        ],
                        selected: {_isOneWay},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() => _isOneWay = newSelection.first);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Flight Route Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Outbound
                          _buildAirportRow(
                            _dep1Controller,
                            _arr1Controller,
                            'From',
                            'To',
                            true,
                          ),
                          const Divider(height: 32),

                          // Date + Swap
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateTile(
                                  context,
                                  'Departure',
                                  _date1,
                                  () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _date1 ??
                                          DateTime.now().add(
                                            const Duration(days: 7),
                                          ),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 730),
                                      ),
                                    );
                                    if (picked != null)
                                      setState(() => _date1 = picked);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              FloatingActionButton.small(
                                heroTag: "swap",
                                onPressed: _swapAirports,
                                child: const Icon(Icons.swap_vert),
                              ),
                            ],
                          ),

                          if (!_isOneWay) ...[
                            const Divider(height: 32),
                            _buildDateTile(context, 'Return', _date2, () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _date2 ??
                                    _date1!.add(const Duration(days: 7)),
                                firstDate: _date1 ?? DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 730),
                                ),
                              );
                              if (picked != null)
                                setState(() => _date2 = picked);
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Travellers Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person_outline, size: 28),
                      title: const Text(
                        'Travellers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$_adt Adult${_adt > 1 ? 's' : ''}${_chd > 0 ? ', $_chd Child' : ''}${_inf > 0 ? ', $_inf Infant' : ''}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showTravellerPicker,
                    ),
                  ),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_loading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 3),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage ?? 'Searching...',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Floating Search Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _performSearch,
        icon: const Icon(Icons.search),
        label: const Text('Search Flights'),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAirportRow(
    TextEditingController from,
    TextEditingController to,
    String labelFrom,
    String labelTo,
    bool showDivider,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: from,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: labelFrom,
              prefixIcon: const Icon(Icons.flight_takeoff, color: Colors.blue),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, color: Colors.grey),
        ),
        Expanded(
          child: TextField(
            controller: to,
            decoration: InputDecoration(
              labelText: labelTo,
              prefixIcon: const Icon(Icons.flight_land, color: Colors.green),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(
    BuildContext context,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.purple),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        date == null
            ? 'Select date'
            : DateFormat('EEE, dd MMM yyyy').format(date),
        style: TextStyle(
          fontSize: 16,
          color: date == null
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_down),
      onTap: onTap,
    );
  }
}

// Traveller Picker Bottom Sheet
class TravellerPicker extends StatefulWidget {
  final int adt, chd, inf;
  final Function(int a, int c, int i) onChanged;

  const TravellerPicker({
    super.key,
    required this.adt,
    required this.chd,
    required this.inf,
    required this.onChanged,
  });

  @override
  State<TravellerPicker> createState() => _TravellerPickerState();
}

class _TravellerPickerState extends State<TravellerPicker> {
  late int adt, chd, inf;

  @override
  void initState() {
    super.initState();
    adt = widget.adt;
    chd = widget.chd;
    inf = widget.inf;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Travellers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildCounter(
            'Adults (12+)',
            adt,
            (v) => setState(() => adt = v.clamp(1, 9)),
          ),
          _buildCounter(
            'Children (2-11)',
            chd,
            (v) => setState(() => chd = v.clamp(0, 9)),
          ),
          _buildCounter(
            'Infants (<2)',
            inf,
            (v) => setState(() => inf = v.clamp(0, adt)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onChanged(adt, chd, inf);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChange(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => onChange(value + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
