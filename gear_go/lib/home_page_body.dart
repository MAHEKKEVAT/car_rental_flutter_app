import 'package:flutter/material.dart';
import 'package:gear_go/car_brand_category.dart';
import 'package:gear_go/search_filter_complex_code.dart';
import 'package:gear_go/filter_car_complex.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:card_loading/card_loading.dart';
import 'car_data_model.dart';
import 'view_car_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarListPage extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> pages;

  const CarListPage({
    super.key,
    required this.selectedIndex,
    required this.pages,
  });

  @override
  _CarListPageState createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CarDataModel> _cars = [];
  bool _isLoading = true;
  String selectedCity = "Mumbai";
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _filterFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchCars();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) {
        _filterFocus.unfocus();
      }
    });
    _filterFocus.addListener(() {
      if (_filterFocus.hasFocus) {
        _searchFocus.unfocus();
      }
    });
  }

  Future<void> _fetchCars() async {
    try {
      // Simulate minimum 1-second loading effect
      DateTime startTime = DateTime.now();
      QuerySnapshot snapshot = await _firestore.collection('CarData').get();
      DateTime endTime = DateTime.now();
      int fetchDuration = endTime.difference(startTime).inMilliseconds;

      setState(() {
        _cars = snapshot.docs.map((doc) {
          return CarDataModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        // Ensure loading state lasts at least 1000ms
        if (fetchDuration < 1000) {
          Future.delayed(Duration(milliseconds: 1000 - fetchDuration), () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        } else {
          _isLoading = false;
        }
      });
    } catch (e) {
      print("Error fetching car data: $e");
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error fetching cars: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: 6, // Number of loading cards to display
        itemBuilder: (context, index) {
          return CardLoading(
            height: 240, // Reduced height to match smaller car card
            width: double.infinity,
            borderRadius: BorderRadius.circular(20),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          );
        },
      );
    }

    return widget.selectedIndex == 0
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchFilterComplexCode(),
                ),
              );
              Fluttertoast.showToast(
                msg: "You Can Filter depend Your Choice!!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
              );
            },
            child: Container(
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600], size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Search Vehicle...",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterCarComplex(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                      Icon(Icons.filter_list, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Car Brands
        CarBrandCategory(),
        SizedBox(height: 16),
        // All Cars Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "All Cars",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Car List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cars.length,
            itemBuilder: (context, index) {
              final car = _cars[index];
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
                      borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.network(
                                  car.carImage1,
                                  height: 160, // Reduced height
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Container(
                                      height: 160,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Container(
                                      height: 160,
                                      color: Colors.grey[200],
                                      child: Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red)),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        '4.9',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    _showAddToFavoritesDialog(context, car);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.favorite_border,
                                        color: Colors.red, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              car.carName,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                car.carName,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              Text(
                                "₹${car.basicPrice}",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          Divider(color: Colors.blue[200], thickness: 1),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_gas_station,
                                      color: Colors.blue[600], size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    car.fuelType,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[800]),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      color: Colors.blue[600], size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    "${car.noOfSeats}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
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
    )
        : widget.pages[widget.selectedIndex];
  }

  void _showAddToFavoritesDialog(BuildContext context, CarDataModel car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add to Favorites?",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      Divider(color: Colors.blue[200]),
                      SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          car.carImage1,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Icon(Icons.error_outline, color: Colors.red),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        car.carName,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .collection('Favourites')
                                  .add({
                                'carDocumentId': car.documentId,
                                'carName': car.carName,
                                'addedAt': FieldValue.serverTimestamp(),
                              });
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: "Added to Favorites!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );
                            } catch (e) {
                              print("Error adding to favorites: $e");
                              Fluttertoast.showToast(
                                msg:
                                "Failed to add to favorites. Please try again.",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: "Please log in to add to favorites.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.orange,
                              textColor: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          elevation: 4,
                        ),
                        child: Text(
                          'Yes, Add',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
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
      },
    );
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _filterFocus.dispose();
    super.dispose();
  }
}