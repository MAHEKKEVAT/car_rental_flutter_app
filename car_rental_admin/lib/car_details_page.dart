import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarDetailsPage extends StatefulWidget {
  final Map<String, dynamic> carData;

  const CarDetailsPage({super.key, required this.carData});

  @override
  _CarDetailsPageState createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final carName = widget.carData['car_name'] ?? 'Unknown';
    final carBrand = widget.carData['car_brand'] ?? 'Unknown';
    final chassisNo = widget.carData['chassis_no'] ?? 'Not provided';
    final engineNo = widget.carData['engine_no'] ?? 'Not provided';
    final features = [
      widget.carData['features1'] ?? '',
      widget.carData['features2'] ?? '',
      widget.carData['features3'] ?? '',
      widget.carData['features4'] ?? '',
      widget.carData['features5'] ?? '',
      widget.carData['features6'] ?? '',
    ].where((f) => f.isNotEmpty).toList();
    final fuelType = widget.carData['fuel_type'] ?? 'Not provided';
    final maxPrice = widget.carData['max_price']?.toString() ?? 'Not provided';
    final noOfSeats = widget.carData['no_of_seats']?.toString() ?? 'Not provided';
    final plusPrice = widget.carData['plus_price']?.toString() ?? 'Not provided';
    final randomID = widget.carData['randomID'] ?? 'Not provided';

    // Collect individual image fields into a list
    final images = [
      widget.carData['car_image1'] as String?,
      widget.carData['car_image2'] as String?,
      widget.carData['car_image3'] as String?,
      widget.carData['car_image4'] as String?,
    ].where((image) => image != null && image.isNotEmpty).cast<String>().toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          carName,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background image with 25% opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Column(
            children: [
              // Image Slider at the top
              Container(
                color: Colors.black, // Ensure background consistency
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() => _currentImageIndex = index);
                        },
                      ),
                      items: images.isNotEmpty
                          ? images.take(4).map((image) {
                        return Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child; // Image loaded
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                    ),
                                  ); // Show yellow indicator while loading
                                },
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.directions_car,
                                  color: Colors.grey,
                                  size: 100,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList()
                          : [
                        // Placeholder when no images
                        Builder(
                          builder: (BuildContext context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: Colors.grey.withOpacity(0.2),
                                child: const Center(
                                  child: Icon(
                                    Icons.directions_car,
                                    color: Colors.grey,
                                    size: 100,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AnimatedSmoothIndicator(
                      activeIndex: _currentImageIndex,
                      count: images.isNotEmpty ? (images.length > 4 ? 4 : images.length) : 1, // 1 for placeholder
                      effect: const WormEffect(
                        dotColor: Colors.grey,
                        activeDotColor: Colors.yellow,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable car details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car Details Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Brand', carBrand),
                            _buildDetailRow('Chassis No', chassisNo),
                            _buildDetailRow('Engine No', engineNo),
                            if (features.isNotEmpty)
                              _buildDetailRow('Features', features.join(', ')),
                            _buildDetailRow('Fuel Type', fuelType),
                            _buildDetailRow('Max Price', '\$$maxPrice'),
                            _buildDetailRow('No of Seats', noOfSeats),
                            _buildDetailRow('Plus Price', '\$$plusPrice'),
                            _buildDetailRow('Random ID', randomID),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              color: Colors.yellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}