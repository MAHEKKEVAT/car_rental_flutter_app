import 'package:car_rental_admin/bottom_navigation_bar/add_car_page.dart';
import 'package:car_rental_admin/utils/active_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'UsersPage.dart';
import 'bottom_navigation_bar/all_cars_page.dart';
import 'reports_page.dart';
import 'bottom_navigation_bar/bookings_car_page.dart';
import 'utils/custom_toast.dart';
import 'package:intl/intl.dart';
import 'user_booking_details_page.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> with TickerProviderStateMixin {
  late AnimationController _carCountController;
  late AnimationController _bookingCountController;
  late AnimationController _revenueController;
  late AnimationController _userCountController;

  late Animation<double> _carCountAnimation;
  late Animation<double> _bookingCountAnimation;
  late Animation<double> _revenueAnimation;
  late Animation<double> _userCountAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers for each metric (2 seconds duration)
    _carCountController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _bookingCountController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _revenueController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _userCountController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Dispose animation controllers to prevent memory leaks
    _carCountController.dispose();
    _bookingCountController.dispose();
    _revenueController.dispose();
    _userCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('car_booking')
          .where('status', isEqualTo: 'accepted')
          .snapshots(),
      builder: (context, bookingSnapshot) {
        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
          );
        }

        if (bookingSnapshot.hasError) {
          print('Error fetching active bookings: ${bookingSnapshot.error}');
          return Center(
            child: Text(
              'Failed to load active bookings. Please try again.',
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 18),
            ),
          );
        }

        final activeBookingCount = bookingSnapshot.data?.docs.length ?? 0;
        final revenue = bookingSnapshot.data?.docs.fold<double>(0, (sum, doc) {
          final booking = doc.data() as Map<String, dynamic>;
          return sum + (booking['totalPrice']?.toDouble() ?? 0);
        }) ?? 0;

        // Set up animations for active bookings and revenue
        _bookingCountAnimation = Tween<double>(begin: 0, end: activeBookingCount.toDouble()).animate(
          CurvedAnimation(parent: _bookingCountController, curve: Curves.easeOut),
        );
        _revenueAnimation = Tween<double>(begin: 0, end: revenue).animate(
          CurvedAnimation(parent: _revenueController, curve: Curves.easeOut),
        );

        // Start animations
        _bookingCountController.forward();
        _revenueController.forward();

        return StreamBuilder<List<QuerySnapshot>>(
          stream: Stream.fromFuture(Future.wait([
            FirebaseFirestore.instance.collection('CarData').get(),
            FirebaseFirestore.instance.collection('Users').get(),
          ])),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                ),
              );
            }

            if (snapshot.hasError) {
              print('Error fetching data: ${snapshot.error}');
              return Center(
                child: Text(
                  'Error fetching data. Please try again.',
                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 18),
                ),
              );
            }

            final carCount = snapshot.data![0].docs.length;
            final userCount = snapshot.data![1].docs.length;

            // Set up animations for cars and users
            _carCountAnimation = Tween<double>(begin: 0, end: carCount.toDouble()).animate(
              CurvedAnimation(parent: _carCountController, curve: Curves.easeOut),
            );
            _userCountAnimation = Tween<double>(begin: 0, end: userCount.toDouble()).animate(
              CurvedAnimation(parent: _userCountController, curve: Curves.easeOut),
            );

            // Start animations
            _carCountController.forward();
            _userCountController.forward();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Welcome back, Admin!',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetricCard(
                              'Total Cars',
                              _carCountAnimation,
                              Icons.directions_car,
                              Colors.yellow,
                              format: (value) => value.toInt().toString(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                    const AllCarsPage(),
                                    transitionsBuilder:
                                        (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                            ),
                            _buildMetricCard(
                              'Active Bookings',
                              _bookingCountAnimation,
                              Icons.book_online,
                              Colors.blue,
                              format: (value) => value.toInt().toString(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AcceptedBookingsPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetricCard(
                              'Revenue',
                              _revenueAnimation,
                              Icons.attach_money,
                              Colors.green,
                              format: (value) => '\$${value.toStringAsFixed(2)}',
                            ),
                            _buildMetricCard(
                              'Customers',
                              _userCountAnimation,
                              Icons.person,
                              Colors.red,
                              format: (value) => value.toInt().toString(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UsersPage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Recent Bookings',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collectionGroup('car_booking')
                              .orderBy('bookingTime', descending: true)
                              .limit(3)
                              .snapshots(),
                          builder: (context, bookingSnapshot) {
                            if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                ),
                              );
                            }

                            if (bookingSnapshot.hasError) {
                              print('Error loading bookings: ${bookingSnapshot.error}');
                              return Text(
                                'Error loading bookings',
                                style: GoogleFonts.poppins(color: Colors.red, fontSize: 18),
                              );
                            }

                            final bookings = bookingSnapshot.data?.docs ?? [];

                            if (bookings.isEmpty) {
                              return Text(
                                'No recent bookings',
                                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 18),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...bookings.map((doc) {
                                  final booking = doc.data() as Map<String, dynamic>;
                                  final customer = booking['userName'] ?? 'Guest';
                                  final car = booking['carName'] ?? 'Unknown';
                                  final pickUp = (booking['pickUpDateTime'] as Timestamp?)?.toDate();
                                  final returnDate = (booking['returnDateTime'] as Timestamp?)?.toDate();
                                  final price = booking['totalPrice']?.toString() ?? '0';
                                  final carImageUrl = booking['carImage1'];

                                  final dateFormat = DateFormat('MMM d');
                                  final bookingDates = pickUp != null && returnDate != null
                                      ? '${dateFormat.format(pickUp)} - ${dateFormat.format(returnDate)}'
                                      : 'N/A';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserBookingDetailsPage(documentReference: doc.reference),
                                        ),
                                      );
                                    },
                                    child: _buildBookingCard(customer, car, bookingDates, '₹$price', carImageUrl),
                                  );
                                }).toList(),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const BookingsAndCarsPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Show All Bookings',
                                    style: GoogleFonts.poppins(
                                      color: Colors.yellow,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(context, 'Add Car', Icons.add_circle, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddCarPage()),
                        );
                        CustomToast.show(context, message: 'Add Car tapped!');
                      }),
                      _buildActionButton(context, 'View Reports', Icons.bar_chart, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReportsPage()),
                        );
                        CustomToast.show(context, message: 'View Reports tapped!');
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard(
      String title,
      Animation<double> animation,
      IconData icon,
      Color color, {
        String Function(double)? format,
        VoidCallback? onTap,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final value = format != null ? format(animation.value) : animation.value.toString();
                  return Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(String customer, String car, String dates, String price, String? carImageUrl) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: $customer",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  car,
                  style: GoogleFonts.poppins(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: Colors.greenAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (carImageUrl != null && carImageUrl.isNotEmpty)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: carImageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 24),
          label: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}