import 'package:flutter/material.dart';
import '../widgets/input_box.dart';
import 'results_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  // keep controllers for compatibility (some widgets may still use them)
  final fromController = TextEditingController();
  final toController = TextEditingController();

  // Fixed set of locations (from your API data)
  final List<String> locations = const ['NYC', 'LAX', 'DXB', 'ADD'];

  // Selected values (dropdown-backed)
  String? selectedFrom;
  String? selectedTo;

  DateTime? departDate;
  DateTime? returnDate;

  // traveller + class
  int travellers = 1;
  final List<String> cabinClasses = const ['Economy', 'Business', 'First'];
  String selectedClass = 'Economy';

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);

    // initialize to the first two different options to avoid identical empty state
    selectedFrom = locations[0];
    selectedTo = locations.length > 1 ? locations[1] : locations[0];
    fromController.text = selectedFrom!;
    toController.text = selectedTo!;

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  Future<void> pickDate(bool isReturn) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );

    if (date != null) {
      setState(() {
        if (isReturn) {
          returnDate = date;
        } else {
          departDate = date;
        }
      });
    }
  }

  String dateToText(DateTime? d) {
    if (d == null) return '';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  void swapFromTo() {
    final a = selectedFrom;
    setState(() {
      selectedFrom = selectedTo;
      selectedTo = a;
      fromController.text = selectedFrom ?? '';
      toController.text = selectedTo ?? '';
    });
  }

  Widget dropdownBox({
    required IconData icon,
    required String hint,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xfff1f1f1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(hint),
                value: value,
                items: locations
                    .take(4) // ensure only 4 shown as you requested
                    .map((loc) => DropdownMenuItem(
                          value: loc,
                          child: Text(loc),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          // suffix (swap) will be added separately where needed
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.close, color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Flight",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs – visual only
            TabBar(
              controller: tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: "Round-trip"),
                Tab(text: "One-way"),
                Tab(text: "Multi-city"),
              ],
            ),

            const SizedBox(height: 20),

            // From (dropdown) with swap button
            Row(
              children: [
                Expanded(
                  child: dropdownBox(
                    icon: Icons.flight_takeoff,
                    hint: "From",
                    value: selectedFrom,
                    onChanged: (v) {
                      if (v == selectedTo) {
                        // avoid picking same as destination - swap instead
                        swapFromTo();
                        return;
                      }
                      setState(() {
                        selectedFrom = v;
                        fromController.text = v ?? '';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // swap button
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f1f1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: swapFromTo,
                    icon: const Icon(Icons.swap_vert),
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),

            // To (dropdown)
            dropdownBox(
              icon: Icons.flight_land,
              hint: "To",
              value: selectedTo,
              onChanged: (v) {
                if (v == selectedFrom) {
                  // avoid picking same as origin - swap instead
                  swapFromTo();
                  return;
                }
                setState(() {
                  selectedTo = v;
                  toController.text = v ?? '';
                });
              },
            ),

            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                Expanded(
                  child: InputBox(
                    icon: Icons.calendar_today,
                    hint: departDate == null
                        ? "Fri, Jul 14"
                        : dateToText(departDate),
                    readOnly: true,
                    onTap: () => pickDate(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InputBox(
                    icon: Icons.calendar_today,
                    hint: returnDate == null
                        ? "Fri, Jul 14"
                        : dateToText(returnDate),
                    readOnly: true,
                    onTap: () => pickDate(true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Traveller count + Class selector row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xfff1f1f1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 10),
                  // Travellers selector
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (travellers > 1) travellers--;
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text("$travellers"),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            travellers++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Cabin class selector
                  DropdownButton<String>(
                    value: selectedClass,
                    underline: const SizedBox(),
                    items: cabinClasses
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => selectedClass = v);
                    },
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),

            const Spacer(),

            // Search Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff4a4f63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (selectedFrom == null ||
                      selectedTo == null ||
                      departDate == null ||
                      selectedFrom == selectedTo) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill all required fields")),
                    );
                    return;
                  }

                  // Pass travellers to ResultsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsPage(
                        from: selectedFrom!.trim(),
                        to: selectedTo!.trim(),
                        date: dateToText(departDate),
                        passengers: travellers, // Pass the number of travelers
                      ),
                    ),
                  );
                },
                child: const Text("Search flights",
                    style: TextStyle(fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}