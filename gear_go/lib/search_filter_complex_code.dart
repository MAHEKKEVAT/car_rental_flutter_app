import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gear_go/view_car_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'car_data_model.dart';

class SearchFilterComplexCode extends StatefulWidget {
  const SearchFilterComplexCode({super.key});

  @override
  State<SearchFilterComplexCode> createState() => _SearchFilterComplexCodeState();
}

class _SearchFilterComplexCodeState extends State<SearchFilterComplexCode> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<CarDataModel> _allCars = []; // Store all cars fetched from Firestore
  List<CarDataModel> _filteredCars = []; // To hold filtered car data
  bool _isLoading = true; // To manage loading state
  String _emptySearchMessage = ''; // Message for empty search results

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
    _fetchCars(); // Fetch cars data on initialization
  }

  Future<void> _fetchCars() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('CarData').get();
      // Store all cars in a separate list
      _allCars = snapshot.docs.map((doc) {
        return CarDataModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      setState(() {
        _filteredCars = _allCars; // Initialize filtered list with all cars
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching car data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCars(String query) {
    if (query.isEmpty) {
      setState(() {
        _emptySearchMessage = 'Enter a keyword to search for vehicles.';
        _filteredCars = _allCars; // Reset to showing all cars when query is empty
      });
      return;
    }

    // Filter cars based on the search query
    final filteredResults = _allCars.where((car) =>
        car.carName.toLowerCase().contains(query.toLowerCase())).toList();

    if (filteredResults.isEmpty) {
      setState(() {
        _filteredCars = [];
        _emptySearchMessage = 'No vehicles found matching your search.';
      });
    } else {
      setState(() {
        _filteredCars = filteredResults;
        _emptySearchMessage = ''; // Clear message when results are found
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Search Filter',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Navigate back
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.black), // Black border
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Fixed Search Row at the Top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search Vehicle...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      _filterCars(value); // Call filter function whenever text changes
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Displaying filtered car results or empty message
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredCars.isEmpty
                ? _buildEmptySearchMessage()
                : ListView.builder(
              itemCount: _filteredCars.length,
              itemBuilder: (context, index) {
                final car = _filteredCars[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewCarPage(carData: car),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.network(
                                    car.carImage1,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(child: CircularProgressIndicator());
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text('Failed to load image', style: TextStyle(color: Colors.red)),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          '4.5', // Placeholder rating; add 'rating' to CarDataModel if needed
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              car.carName,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${car.basicPrice}/hour",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.local_gas_station, color: Colors.blue[600], size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      car.fuelType,
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue[600], size: 18),
                                SizedBox(width: 4),
                                Text(
                                  "${car.noOfSeats} Seats",
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
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
            ),
          ),
        ],
      ),
    );
  }

  // Build empty search message widget with an image above
  Widget _buildEmptySearchMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/profile.png', // Adjust the path for your image asset
            height: 100, // Set the height of the image
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          Text(
            _emptySearchMessage.isEmpty
                ? 'No vehicles found matching your search.'
                : _emptySearchMessage,
            style: GoogleFonts.poppins(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}