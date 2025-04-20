import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_rental_admin/user_booking_details_page.dart';


class AcceptedBookingsPage extends StatelessWidget {
  const AcceptedBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('car_booking')
                  .where('status', isEqualTo: 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  print('Error fetching bookings: ${snapshot.error}');
                  return const Center(child: Text('Error fetching data'));
                }

                final bookings = snapshot.data?.docs ?? [];

                if (bookings.isEmpty) {
                  return const Center(child: Text('No accepted bookings found'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accepted Bookings',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'All accepted car bookings',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index].data() as Map<String, dynamic>;
                          final carName = booking['carName'] ?? 'Unknown';
                          final brand = booking['car_brand'] ?? 'Not provided';
                          final totalPrice = booking['totalPrice']?.toString() ?? 'Not provided';
                          final status = booking['status'] ?? 'Unknown';
                          final carImage1 = booking['carImage1'] ?? 'assets/images/car.png';
                          final distance = booking['distance']?.toString() ?? 'N/A';
                          final seats = booking['seats'] ?? 'N/A';
                          final documentReference = bookings[index].reference;

                          return GestureDetector(
                            onTap: () {
                              print('Navigating to documentReference: ${documentReference.path}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserBookingDetailsPage(documentReference: documentReference),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.grey[900],
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        carImage1,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow));
                                        },
                                        errorBuilder: (context, error, stackTrace) =>
                                        const CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow)),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            carName,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Brand: $brand',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[400],
                                              fontSize: 16,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Distance: $distance km, Seats: $seats',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '₹$totalPrice',
                                            style: GoogleFonts.poppins(
                                              color: Colors.yellow,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      status,
                                      style: GoogleFonts.poppins(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}