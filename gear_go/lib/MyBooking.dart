import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'HomePage.dart';
import 'car_booking_model.dart';
import 'my_booking_car_view_page.dart';

class MyBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyBookingPage();
  }
}

class MyBookingPage extends StatefulWidget {
  @override
  _MyBookingPageState createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<CarBooking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _bookings = [];
        });
        Fluttertoast.showToast(
            msg: "Please log in to view bookings", toastLength: Toast.LENGTH_SHORT);
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('car_booking')
          .orderBy('bookingTime', descending: true)
          .get();

      List<CarBooking> bookings = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CarBooking.fromFirestore(data, doc.id);
      }).toList();

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _bookings = [];
      });
      Fluttertoast.showToast(
          msg: "Error fetching bookings: $e", toastLength: Toast.LENGTH_LONG);
      print('Error fetching bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation via system button
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
            onPressed: () {
              // Navigate to HomePage and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
          title: Text(
            'My Booking History',
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 16),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(
            child: LoadingAnimationWidget.dotsTriangle(
                color: Colors.blue[700]!, size: 60))
            : TabBarView(
          controller: _tabController,
          children: [
            _buildBookingList(_bookings
                .where((b) => b.status == 'Pending' || b.status == 'Confirmed')
                .toList()),
            _buildBookingList(
                _bookings.where((b) => b.status == 'Completed').toList()),
            _buildBookingList(
                _bookings.where((b) => b.status == 'Cancelled').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<CarBooking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 100, color: Colors.blue[200]),
            SizedBox(height: 20),
            Text(
              'No bookings found.',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MyBookingCarViewPage(booking: booking),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween =
                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(
                        position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          booking.carImage1,
                          width: 100,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 100,
                            height: 70,
                            color: Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    booking.carName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                    _getStatusColor(booking.status).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    booking.status,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: _getStatusColor(booking.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    color: Colors.blue[600], size: 16),
                                SizedBox(width: 6),
                                Text(
                                  DateFormat('d MMM, yyyy')
                                      .format(booking.pickUpDateTime.toDate()),
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey[800]),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.attach_money_outlined,
                                    color: Colors.blue[700], size: 16),
                                SizedBox(width: 6),
                                Text(
                                  '₹${booking.totalPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: Colors.blue[600], size: 16),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${booking.fromAddress} to ${booking.toAddress}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.grey[800]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.grey[600]!;
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}