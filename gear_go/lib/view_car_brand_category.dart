import 'package:flutter/material.dart';
import 'package:gear_go/view_car_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'car_data_model.dart';
import 'brand_model.dart';

class ViewCarBrandCategory extends StatelessWidget {
  final String title;
  final String brandType;
  final BrandModel brand;

  const ViewCarBrandCategory({
    Key? key,
    required this.title,
    required this.brandType,
    required this.brand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blue[800]),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          _BrandInfoCard(brand: brand),
          Expanded(
            child: CarList(brandType: brandType),
          ),
        ],
      ),
    );
  }
}

class _BrandInfoCard extends StatelessWidget {
  final BrandModel brand;

  const _BrandInfoCard({Key? key, required this.brand}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: brand.imageUrl.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    brand.imageUrl,
                    fit: BoxFit.contain,
                    color: Colors.blue[800],
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return LoadingAnimationWidget.dotsTriangle(
                        color: Colors.blue[700]!,
                        size: 30,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.error_outline,
                      color: Colors.blue[800],
                      size: 30,
                    ),
                  ),
                )
                    : Icon(
                  Icons.directions_car_outlined,
                  size: 30,
                  color: Colors.blue[800],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                brand.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarList extends StatefulWidget {
  final String brandType;

  const CarList({Key? key, required this.brandType}) : super(key: key);

  @override
  State<CarList> createState() => _CarListState();
}

class _CarListState extends State<CarList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CarDataModel> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('CarData').where('car_brand', isEqualTo: widget.brandType).get();
      setState(() {
        _cars = snapshot.docs.map((doc) {
          return CarDataModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching car data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
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
          child: LoadingAnimationWidget.dotsTriangle(color: Colors.blue[700]!, size: 50),
        ),
      );
    }
    if (_cars.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.car_repair, size: 60, color: Colors.blue[600]),
              SizedBox(height: 12),
              Text(
                'No cars available for this brand.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _cars.length,
      itemBuilder: (context, index) {
        final car = _cars[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewCarPage(carData: car)),
            );
          },
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            car.carImage1,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 220,
                                child: Center(child: CircularProgressIndicator(color: Colors.blue[700])),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 220,
                                color: Colors.grey[200],
                                child: Center(child: Icon(Icons.error, color: Colors.red)),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
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
                                  '4.9',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: EdgeInsets.all(6),
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
                            child: Icon(Icons.favorite_border, color: Colors.red, size: 24),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        car.carName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          car.carName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        Text(
                          "₹${car.basicPrice}",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.blue[200]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_gas_station, color: Colors.blue[600], size: 20),
                            SizedBox(width: 6),
                            Text(
                              car.fuelType,
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue[600], size: 20),
                            SizedBox(width: 6),
                            Text(
                              "${car.noOfSeats}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
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
    );
  }
}