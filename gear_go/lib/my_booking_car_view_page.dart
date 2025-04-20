import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'car_booking_model.dart';

class MyBookingCarViewPage extends StatefulWidget {
  final CarBooking booking;

  const MyBookingCarViewPage({Key? key, required this.booking}) : super(key: key);

  @override
  _MyBookingCarViewPageState createState() => _MyBookingCarViewPageState();
}

class _MyBookingCarViewPageState extends State<MyBookingCarViewPage>
    with SingleTickerProviderStateMixin {
  late CarBooking _booking;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking; // Initialize with the passed booking
    _fetchBookingFromDB(); // Fetch the latest booking data from Firestore
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookingFromDB() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('car_booking')
          .doc(widget.booking.id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _booking = CarBooking.fromFirestore(data, doc.id);
          _isLoading = false;
        });
      } else {
        throw Exception("Booking not found");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching booking: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        textColor: Colors.white,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Confirm Cancellation',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.blue[900])),
        content: Text('Are you sure you want to cancel this booking?',
            style: GoogleFonts.poppins(color: Colors.grey[800])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No',
                style: GoogleFonts.poppins(
                    color: Colors.blue[800], fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes',
                style: GoogleFonts.poppins(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('car_booking')
          .doc(_booking.id)
          .update({'status': 'Cancelled'});

      setState(() {
        _booking = CarBooking(
          id: _booking.id,
          documentId: _booking.documentId,
          fromLocation: _booking.fromLocation,
          toLocation: _booking.toLocation,
          fromAddress: _booking.fromAddress,
          toAddress: _booking.toAddress,
          pickUpDateTime: _booking.pickUpDateTime,
          returnDateTime: _booking.returnDateTime,
          subscription: _booking.subscription,
          seats: _booking.seats,
          distance: _booking.distance,
          totalPrice: _booking.totalPrice,
          bookingTime: _booking.bookingTime,
          status: 'Cancelled',
          carImage1: _booking.carImage1,
          carName: _booking.carName,
          carBrand: _booking.carBrand,
          paymentMethod: _booking.paymentMethod,
          userName: _booking.userName,
          userEmail: _booking.userEmail,
          userMobile: _booking.userMobile,
          userCity: _booking.userCity,
          userState: _booking.userState,
          userCountry: _booking.userCountry,
          userPinCode: _booking.userPinCode,
          userLicense: _booking.userLicense,
        );
      });

      Fluttertoast.showToast(
        msg: "Booking cancelled successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green.withOpacity(0.9),
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error cancelling booking: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          _isLoading ? 'Loading...' : _booking.carName,
          style: GoogleFonts.poppins(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
        child: LoadingAnimationWidget.dotsTriangle(
          color: Colors.blue[700]!,
          size: 70,
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Image and Status
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue[200]!.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _booking.carImage1.isNotEmpty
                              ? _booking.carImage1
                              : 'https://via.placeholder.com/250',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: LoadingAnimationWidget.dotsTriangle(
                                color: Colors.blue[700]!,
                                size: 40,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network('https://via.placeholder.com/250'),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(_booking.status),
                              _getStatusColor(_booking.status)
                                  .withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _booking.status,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Car Details Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Car Details',
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900]),
                      ),
                      Divider(color: Colors.blue[200], thickness: 2),
                      SizedBox(height: 15),
                      _buildDetailRow(
                          'Car Brand', _booking.carBrand ?? 'N/A',
                          Icons.local_taxi),
                      _buildDetailRow('Car Name', _booking.carName,
                          Icons.directions_car),
                      _buildDetailRow('Total Price',
                          '₹${_booking.totalPrice.toStringAsFixed(2)}',
                          Icons.attach_money),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Booking Details Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900]),
                      ),
                      Divider(color: Colors.blue[200], thickness: 2),
                      SizedBox(height: 15),
                      _buildDetailRow(
                          'Booking ID',
                          _booking.id.length > 10
                              ? _booking.id.substring(0, 10) + '...'
                              : _booking.id,
                          Icons.confirmation_number),
                      _buildDetailRow('Document ID', _booking.documentId,
                          Icons.description),
                      _buildDetailRow('Pickup Location', _booking.fromAddress,
                          Icons.location_on),
                      _buildDetailRow('Drop-off Location', _booking.toAddress,
                          Icons.location_off),
                      _buildDetailRow(
                          'Pick-Up Date',
                          DateFormat('d MMM, yyyy HH:mm')
                              .format(_booking.pickUpDateTime.toDate()),
                          Icons.calendar_today),
                      _buildDetailRow(
                          'Return Date',
                          DateFormat('d MMM, yyyy HH:mm')
                              .format(_booking.returnDateTime.toDate()),
                          Icons.calendar_today),
                      _buildDetailRow('Distance',
                          '${_booking.distance.toStringAsFixed(1)} km',
                          Icons.straighten),
                      _buildDetailRow('Subscription',
                          _booking.subscription ?? 'N/A', Icons.subscriptions),
                      _buildDetailRow('Seats', _booking.seats ?? 'N/A',
                          Icons.event_seat),
                      _buildDetailRow(
                          'Booking Time',
                          DateFormat('d MMM, yyyy HH:mm')
                              .format(_booking.bookingTime.toDate()),
                          Icons.access_time),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Payment Details Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Details',
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900]),
                      ),
                      Divider(color: Colors.blue[200], thickness: 2),
                      SizedBox(height: 15),
                      _buildDetailRow('Payment Method',
                          _booking.paymentMethod ?? 'N/A', Icons.payment),
                      _buildDetailRow('Total Amount',
                          '₹${_booking.totalPrice.toStringAsFixed(2)}',
                          Icons.attach_money),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // User Details Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Details',
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900]),
                      ),
                      Divider(color: Colors.blue[200], thickness: 2),
                      SizedBox(height: 15),
                      _buildDetailRow('Name', _booking.userName ?? 'N/A',
                          Icons.person),
                      _buildDetailRow('Email', _booking.userEmail ?? 'N/A',
                          Icons.email),
                      _buildDetailRow('Mobile', _booking.userMobile ?? 'N/A',
                          Icons.phone),
                      _buildDetailRow('City', _booking.userCity ?? 'N/A',
                          Icons.location_city),
                      _buildDetailRow('State', _booking.userState ?? 'N/A',
                          Icons.location_on),
                      _buildDetailRow('Country', _booking.userCountry ?? 'N/A',
                          Icons.public),
                      _buildDetailRow('Pin Code', _booking.userPinCode ?? 'N/A',
                          Icons.pin_drop),
                      _buildDetailRow('License', _booking.userLicense ?? 'N/A',
                          Icons.card_membership),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Cancel Button
              if (_booking.status == 'Pending' || _booking.status == 'Confirmed')
                Center(
                  child: ElevatedButton(
                    onPressed: () => _cancelBooking(context),
                    style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                      shadowColor: Colors.redAccent.withOpacity(0.5),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ).copyWith(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.pressed))
                          return Colors.red[800]!;
                        return Colors.redAccent;
                      }),
                      overlayColor:
                      MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[700]!, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'Cancel Booking',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[100]!, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[200]!.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.blue[800], size: 22),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                      fontSize: 15, color: Colors.grey[700], height: 1.2),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green[700]!;
      case 'Pending':
        return Colors.orange[700]!;
      case 'Completed':
        return Colors.grey[600]!;
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}