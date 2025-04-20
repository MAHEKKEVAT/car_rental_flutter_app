import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../car_details_page.dart';

class AllCarsPage extends StatefulWidget {
  const AllCarsPage({super.key});

  @override
  _AllCarsPageState createState() => _AllCarsPageState();
}

class _AllCarsPageState extends State<AllCarsPage> {
  String? _selectedBrand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            ),
          ),
        ),
        title: Text(
          'All Cars',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.yellow.withOpacity(0.3),
      ),
      body: Stack(
        children: [
          // Background image with 20% opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Filter
                  Text(
                    'Filter by Brand',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('CarData').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final brands = ['All', ...snapshot.data!.docs
                          .map((doc) => doc['car_brand'] as String? ?? 'Unknown')
                          .where((brand) => brand.isNotEmpty)
                          .toSet()];
                      return SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: brands.length,
                          itemBuilder: (context, index) {
                            final brand = brands[index];
                            final isSelected = _selectedBrand == brand || (brand == 'All' && _selectedBrand == null);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  brand,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedBrand = brand == 'All' ? null : brand;
                                    });
                                  }
                                },
                                selectedColor: Colors.yellow,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? Colors.yellow : Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                elevation: isSelected ? 4 : 0,
                                pressElevation: 8,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Cars List
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('CarData').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No cars found',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }

                      final cars = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final carBrand = data['car_brand'] as String? ?? 'Unknown';
                        return _selectedBrand == null || carBrand == _selectedBrand;
                      }).toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cars.length,
                        itemBuilder: (context, index) {
                          final carData = cars[index].data() as Map<String, dynamic>;
                          final carName = carData['car_name'] as String? ?? 'Unknown';
                          final carBrand = carData['car_brand'] as String? ?? 'Unknown';
                          final images = (carData['images'] as List<dynamic>?)?.cast<String>() ?? [];
                          final carImage1 = images.isNotEmpty ? images[0] : null;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarDetailsPage(carData: carData),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              transform: Matrix4.identity()..scale(1.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Car Image on Left
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: carImage1 == null
                                          ? Border.all(color: Colors.yellow, width: 2)
                                          : null,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: carImage1 != null
                                          ? CachedNetworkImage(
                                        imageUrl: carImage1,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            border: Border.all(color: Colors.yellow, width: 2),
                                          ),
                                          child: const Icon(
                                            Icons.directions_car,
                                            color: Colors.yellow,
                                            size: 50,
                                          ),
                                        ),
                                      )
                                          : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          border: Border.all(color: Colors.yellow, width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.directions_car,
                                          color: Colors.yellow,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Car Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          carName,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          carBrand,
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to view details',
                                          style: GoogleFonts.poppins(
                                            color: Colors.yellow.withOpacity(0.7),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}