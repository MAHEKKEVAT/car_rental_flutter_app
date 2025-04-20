import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'car_data_model.dart';

class FilterCarComplex extends StatefulWidget {
  const FilterCarComplex({super.key});

  @override
  State<FilterCarComplex> createState() => _FilterCarComplexState();
}

class _FilterCarComplexState extends State<FilterCarComplex> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CarDataModel> _cars = [];
  List<CarDataModel> _filteredCars = [];
  bool _isLoading = true;

  // Filter state
  String _selectedBrand = 'All';
  double _priceRangeMin = 50.0;
  double _priceRangeMax = 400.0;
  double _selectedPrice = 50.0;
  String _selectedRating = 'All';

  final List<Map<String, dynamic>> _ratings = [
    {'label': '4.5 and above', 'value': '4.5', 'min': 4.5},
    {'label': '4.0 - 4.5', 'value': '4.0-4.5', 'min': 4.0, 'max': 4.5},
    {'label': '3.5 - 4.0', 'value': '3.5-4.0', 'min': 3.5, 'max': 4.0},
    {'label': '3.0 - 3.5', 'value': '3.0-3.5', 'min': 3.0, 'max': 3.5},
    {'label': '2.5 - 3.0', 'value': '2.5-3.0', 'min': 2.5, 'max': 3.0},
  ];

  // Dynamically generate unique brands from CarData
  List<String> get _brands {
    Set<String> uniqueBrands = {'All'};
    for (var car in _cars) {
      if (car.carBrand.isNotEmpty) {
        uniqueBrands.add(car.carBrand);
      }
    }
    return uniqueBrands.toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    setState(() => _isLoading = true);
    try {
      QuerySnapshot snapshot = await _firestore.collection('CarData').get();
      setState(() {
        _cars = snapshot.docs.map((doc) {
          return CarDataModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        _filteredCars = List.from(_cars); // Initial unfiltered list
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching cars: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCars = _cars.where((car) {
        bool matchesPrice = car.basicPrice <= _selectedPrice;
        bool matchesRating = _selectedRating == 'All' ||
            (_ratings.any((rating) => rating['value'] == _selectedRating &&
                (car.basicPrice >= (rating['min'] as double) * 100 &&
                    (rating['max'] == null || car.basicPrice <= (rating['max'] as double) * 100))));
        bool matchesBrand = _selectedBrand == 'All' ||
            car.carBrand.toLowerCase() == _selectedBrand.toLowerCase();

        return matchesPrice && matchesRating && matchesBrand;
      }).toList();
    });
    Fluttertoast.showToast(
      msg: "Filters applied! ${_filteredCars.length} cars found.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = 'All';
      _priceRangeMin = 50.0;
      _priceRangeMax = 400.0;
      _selectedPrice = 50.0;
      _selectedRating = 'All';
      _filteredCars = List.from(_cars);
    });
    Fluttertoast.showToast(
      msg: "Filters reset!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filter',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Brand
            Text(
              'Car Brand',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _brands.length,
                itemBuilder: (context, index) {
                  final brand = _brands[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(brand),
                      selected: _selectedBrand == brand,
                      onSelected: (selected) {
                        setState(() => _selectedBrand = brand);
                      },
                      selectedColor: Colors.blue[700],
                      backgroundColor: Colors.grey[200],
                      labelStyle: GoogleFonts.poppins(
                        color: _selectedBrand == brand ? Colors.white : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Price Range
            Text(
              'Price Range (Hourly)',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _selectedPrice,
              min: _priceRangeMin,
              max: _priceRangeMax,
              divisions: 7,
              label: '\$${_selectedPrice.round()}',
              activeColor: Colors.blue,
              inactiveColor: Colors.grey[300],
              onChanged: (value) {
                setState(() => _selectedPrice = value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${_priceRangeMin.round()}', style: GoogleFonts.poppins()),
                Text('\$${_priceRangeMax.round()}', style: GoogleFonts.poppins()),
              ],
            ),
            const SizedBox(height: 16),

            // Reviews
            Text(
              'Reviews',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._ratings.map((rating) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                      Text(
                        ' ${rating['label']}',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                  Radio<String>(
                    value: rating['value'] as String,
                    groupValue: _selectedRating,
                    onChanged: (value) {
                      setState(() => _selectedRating = value!);
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 16),

            // Brand (Removed as per instructions, already handled above)

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset Filter',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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