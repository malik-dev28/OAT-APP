import 'package:flutter/material.dart';

void main() {
  runApp(const CampusMapApp());
}

class CampusMapApp extends StatelessWidget {
  const CampusMapApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Campus Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const MapScreen(),
    );
  }
}

class CampusLocation {
  final String id;
  final String name;
  final String type;
  final String description;
  final Offset position;
  final String? imageUrl;

  CampusLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.description = '',
    this.imageUrl,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final List<CampusLocation> _approvedLocations = [
    CampusLocation(
      id: "1",
      name: "Main Cafeteria",
      type: "cafeteria",
      description: "Main dining hall serving breakfast, lunch, and dinner",
      position: const Offset(0.4, 0.3),
      imageUrl:
          "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400",
    ),
    CampusLocation(
      id: "2",
      name: "Central Library",
      type: "library",
      description: "24/7 access to books, study spaces, and digital resources",
      position: const Offset(0.6, 0.4),
      imageUrl:
          "https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=400",
    ),
    CampusLocation(
      id: "3",
      name: "Dormitory A",
      type: "dorm",
      description: "Student residence with single and double occupancy rooms",
      position: const Offset(0.2, 0.7),
      imageUrl:
          "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400",
    ),
    CampusLocation(
      id: "4",
      name: "Engineering Building",
      type: "office",
      description: "Home to Computer Science and Engineering departments",
      position: const Offset(0.8, 0.6),
      imageUrl:
          "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=400",
    ),
    CampusLocation(
      id: "5",
      name: "University Gym",
      type: "gym",
      description: "Fitness center with cardio and weight training equipment",
      position: const Offset(0.5, 0.8),
      imageUrl:
          "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400",
    ),
    CampusLocation(
      id: "6",
      name: "Campus Coffee Shop",
      type: "cafeteria",
      description: "Coffee, snacks, and study space",
      position: const Offset(0.45, 0.35),
      imageUrl:
          "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400",
    ),
  ];

  final List<CampusLocation> _pendingLocations = [];
  final List<String> _types = [
    "cafeteria",
    "dorm",
    "library",
    "office",
    "lab",
    "gym",
    "other",
  ];

  late AnimationController _animationController;
  late PageController _pageController;
  int _currentPage = 0;
  bool _showMapView = true;
  String _selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Color _getColor(String type) {
    switch (type) {
      case "cafeteria":
        return const Color(0xFFE74C3C);
      case "dorm":
        return const Color(0xFF3498DB);
      case "library":
        return const Color(0xFF2ECC71);
      case "office":
        return const Color(0xFFF39C12);
      case "lab":
        return const Color(0xFF9B59B6);
      case "gym":
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "cafeteria":
        return Icons.restaurant;
      case "dorm":
        return Icons.hotel;
      case "library":
        return Icons.library_books;
      case "office":
        return Icons.business_center;
      case "lab":
        return Icons.science;
      case "gym":
        return Icons.fitness_center;
      default:
        return Icons.place;
    }
  }

  void _addLocation(Offset tapPosition) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    String selectedType = _types[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Add New Location",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(nameCtrl, "Location Name", Icons.place),
                      const SizedBox(height: 16),
                      _buildTextField(
                        descCtrl,
                        "Description (optional)",
                        Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildTypeSelector(
                        selectedType,
                        (v) => selectedType = v!,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.isEmpty) return;
                        setState(() {
                          _pendingLocations.add(
                            CampusLocation(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: nameCtrl.text,
                              type: selectedType,
                              description: descCtrl.text,
                              position: Offset(
                                tapPosition.dx /
                                    MediaQuery.of(context).size.width,
                                tapPosition.dy /
                                    MediaQuery.of(context).size.height,
                              ),
                            ),
                          );
                        });
                        Navigator.pop(ctx);
                        _showSuccessSnackbar();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTypeSelector(
    String selectedType,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Location Type",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types.map((type) {
            final isSelected = type == selectedType;
            return ChoiceChip(
              label: Text(type.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              backgroundColor: Colors.grey[100],
              selectedColor: _getColor(type),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Submitted! Waiting for admin approval"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showAdminPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Admin Panel - Pending Locations",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _pendingLocations.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No pending locations",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _pendingLocations.length,
                      itemBuilder: (ctx, i) {
                        final loc = _pendingLocations[i];
                        return _buildPendingLocationCard(loc, i);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingLocationCard(CampusLocation loc, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getColor(loc.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getIcon(loc.type), color: _getColor(loc.type)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Type: ${loc.type}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (loc.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(loc.description, style: TextStyle(color: Colors.grey[700])),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _pendingLocations.removeAt(index)),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text("Reject"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _approvedLocations.add(loc);
                      _pendingLocations.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("Approve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildLocationCard(CampusLocation loc) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 120,
              color: _getColor(loc.type).withOpacity(0.2),
              child: loc.imageUrl != null
                  ? Image.network(loc.imageUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        _getIcon(loc.type),
                        size: 48,
                        color: _getColor(loc.type),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getColor(loc.type),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getIcon(loc.type),
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  loc.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getColor(loc.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        loc.type.toUpperCase(),
                        style: TextStyle(
                          color: _getColor(loc.type),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showLocationDetails(loc),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.indigo,
                      ),
                      child: const Row(
                        children: [
                          Text("Details"),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails(CampusLocation loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getColor(loc.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIcon(loc.type),
                            size: 32,
                            color: _getColor(loc.type),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc.type.toUpperCase(),
                                style: TextStyle(
                                  color: _getColor(loc.type),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    if (loc.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          loc.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildMapPreview(loc),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview(CampusLocation loc) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Custom Map Background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.green[50]!],
              ),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: _CampusMapPainter(loc.position),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.navigation, size: 16, color: _getColor(loc.type)),
                  const SizedBox(width: 4),
                  Text(
                    "Navigate",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getColor(loc.type),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<CampusLocation> get _filteredLocations {
    if (_selectedFilter == "all") return _approvedLocations;
    return _approvedLocations
        .where((loc) => loc.type == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Campus Map"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: _showAdminPanel,
            tooltip: "Admin Panel",
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with toggle and filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // View Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton("Map View", Icons.map, true),
                      _buildToggleButton("List View", Icons.list, false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip("all", "All", Icons.all_inclusive),
                      ..._types.map(
                        (type) => _buildFilterChip(type, type, _getIcon(type)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _showMapView ? _buildMapView(size) : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Tap anywhere on the map to add a new location",
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        label: const Text("Add Location"),
        icon: const Icon(Icons.add_location_alt),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildToggleButton(String text, IconData icon, bool isMapView) {
    final isSelected = _showMapView == isMapView;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showMapView = isMapView),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = value),
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : _getColor(value),
        ),
        backgroundColor: Colors.white,
        selectedColor: _getColor(value),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? _getColor(value) : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildMapView(Size size) {
    return Stack(
      children: [
        // Custom Map Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[50]!, Colors.green[50]!],
            ),
          ),
          child: CustomPaint(
            size: size,
            painter: _CampusMapPainter(Offset.zero),
          ),
        ),

        // Location Pins
        ..._filteredLocations.map((loc) {
          final double x = loc.position.dx * size.width;
          final double y = loc.position.dy * size.height;

          return Positioned(
            left: x - 20,
            top: y - 40,
            child: GestureDetector(
              onTap: () => _showLocationDetails(loc),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(loc.type),
                      color: _getColor(loc.type),
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      loc.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getColor(loc.type),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Tap to add location
        Positioned.fill(
          child: GestureDetector(
            onTapUp: (details) => _addLocation(details.localPosition),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return _filteredLocations.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No locations found",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  "Try changing your filters",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) =>
                  _buildLocationCard(_filteredLocations[index]),
            ),
          );
  }
}

class _CampusMapPainter extends CustomPainter {
  final Offset selectedLocation;

  _CampusMapPainter(this.selectedLocation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw grass background
    paint.color = Colors.green[100]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw roads
    paint.color = Colors.grey[400]!;

    // Main vertical road
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.08,
        height: size.height,
      ),
      paint,
    );

    // Main horizontal road
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width,
        height: size.height * 0.08,
      ),
      paint,
    );

    // Draw buildings
    _drawBuilding(
      canvas,
      size,
      Offset(size.width * 0.2, size.height * 0.2),
      Colors.blue[300]!,
      "Library",
    );
    _drawBuilding(
      canvas,
      size,
      Offset(size.width * 0.7, size.height * 0.3),
      Colors.orange[300]!,
      "Cafeteria",
    );
    _drawBuilding(
      canvas,
      size,
      Offset(size.width * 0.3, size.height * 0.7),
      Colors.purple[300]!,
      "Dormitory",
    );
    _drawBuilding(
      canvas,
      size,
      Offset(size.width * 0.8, size.height * 0.6),
      Colors.red[300]!,
      "Gym",
    );

    // Draw selected location marker if any
    if (selectedLocation != Offset.zero) {
      final markerPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          selectedLocation.dx * size.width,
          selectedLocation.dy * size.height,
        ),
        8,
        markerPaint,
      );
    }
  }

  void _drawBuilding(
    Canvas canvas,
    Size size,
    Offset position,
    Color color,
    String label,
  ) {
    final paint = Paint()..color = color;
    final buildingSize = Size(size.width * 0.15, size.height * 0.2);

    canvas.drawRect(
      Rect.fromCenter(
        center: position,
        width: buildingSize.width,
        height: buildingSize.height,
      ),
      paint,
    );

    // Add building shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(position.dx + 4, position.dy + 4),
        width: buildingSize.width,
        height: buildingSize.height,
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
