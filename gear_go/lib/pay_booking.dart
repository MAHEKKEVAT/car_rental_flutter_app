import 'package:flutter/material.dart';
import 'package:gear_go/MyBooking.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'CustomNotificationClass.dart';
import 'car_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'privacy.dart';
import 'show_booking_information.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PayBooking extends StatefulWidget {
  final String documentId;
  final String fromLocation;
  final String toLocation;
  final String fromAddress;
  final String toAddress;
  final DateTime pickUpDateTime;
  final DateTime returnDateTime;
  final double coverDistance;

  const PayBooking({
    super.key,
    required this.documentId,
    required this.fromLocation,
    required this.toLocation,
    required this.fromAddress,
    required this.toAddress,
    required this.pickUpDateTime,
    required this.returnDateTime,
    required this.coverDistance,
  });

  @override
  State<PayBooking> createState() => _PayBookingState();
}

class _PayBookingState extends State<PayBooking> {
  bool isChecked = false;
  String? _errorMessage;
  CarDataModel? carData;
  String? selectedSeats;
  String? selectedSubscription;
  double calculatedPrice = 0.0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _fetchCarData();
    _fetchUserData();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchCarData() async {
    try {
      final doc = await _firestore.collection('CarData').doc(widget.documentId).get();
      if (doc.exists) {
        setState(() => carData = CarDataModel.fromJson(doc.data()! as Map<String, dynamic>, widget.documentId));
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching car data: $e", toastLength: Toast.LENGTH_SHORT);
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('Users').doc(user.uid).get();
        if (!userDoc.exists || userDoc.data() == null) {
          await _firestore.collection('Users').doc(user.uid).set({
            'name': 'No Name',
            'email': 'nogmail@gmail.com',
            'mobile_number': '1234567890',
            'city': 'CITY',
            'country': 'India',
            'state': 'Gujrat',
            'license_no': 'User@Licence2025',
            'pin_code': '1234568789',
            'payment_method': 'RazorPay',
          }, SetOptions(merge: true));
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error fetching user data: $e", toastLength: Toast.LENGTH_SHORT);
      }
    }
  }

  void _calculatePrice(String? seats, String? subscription) {
    if (seats != null && subscription != null && carData != null) {
      final pricePerKm = subscription == 'BASIC'
          ? carData!.basicPrice.toDouble()
          : subscription == 'PLUS'
          ? carData!.plusPrice.toDouble()
          : carData!.maxPrice.toDouble();
      setState(() {
        calculatedPrice = pricePerKm * widget.coverDistance;
        selectedSeats = seats;
        selectedSubscription = subscription;
      });
    } else {
      setState(() => calculatedPrice = 0);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "Payment Successful! Payment ID: ${response.paymentId}");
    _saveCarBooking();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment Failed: ${response.code} - ${response.message}");
    Navigator.pop(context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
  }

  void _openRazorpay() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final options = {
        'key': 'rzp_test_VMCy3olYpU8PYs',
        'amount': (calculatedPrice * 100).toInt(),
        'name': 'Car Rental Service',
        'description': 'Payment for car booking',
        'prefill': {'contact': '', 'email': ''},
        'external': {'wallets': ['paytm']},
      };

      _firestore.collection('Users').doc(user.uid).get().then((userDoc) {
        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          options['prefill'] = {
            'contact': userData['mobile_number'] ?? '',
            'email': userData['email'] ?? '',
          };
        }
        _razorpay.open(options);
      }).catchError((e) {
        Fluttertoast.showToast(msg: "Error fetching user data: $e");
      });
    }
  }

  Future<Map<String, dynamic>?> _saveCarBooking() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final carBookingRef = _firestore.collection('Users').doc(userId).collection('car_booking');
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      final userData = userDoc.exists ? userDoc.data() ?? {} : {};

      if (!userDoc.exists) {
        await _firestore.collection('Users').doc(userId).set({}, SetOptions(merge: true));
      }

      final bookingData = {
        'documentId': widget.documentId,
        'fromLocation': widget.fromLocation,
        'toLocation': widget.toLocation,
        'fromAddress': widget.fromAddress,
        'toAddress': widget.toAddress,
        'pickUpDateTime': Timestamp.fromDate(widget.pickUpDateTime),
        'returnDateTime': Timestamp.fromDate(widget.returnDateTime),
        'subscription': selectedSubscription,
        'seats': selectedSeats,
        'distance': widget.coverDistance,
        'totalPrice': calculatedPrice,
        'bookingTime': Timestamp.now(),
        'status': 'Pending',
        'carImage1': carData!.carImage1,
        'carName': carData!.carName,
        'car_brand': carData!.carBrand,
        'payment_method': 'RazorPay',
        'userName': userData['name'] ?? 'Not Found',
        'userEmail': userData['email'] ?? 'Not Found',
        'userMobile': userData['mobile_number'] ?? 'Not Found',
        'userCity': userData['city'] ?? 'Not Found',
        'userState': userData['state'] ?? 'Not Found',
        'userCountry': userData['country'] ?? 'Not Found',
        'userLicense': userData['license_no'] ?? 'Not Found',
        'userPinCode': userData['pin_code'] ?? 'Not Found',
      };

      await carBookingRef.add(bookingData);
      await _postCarRentalNotification();
      _showReceiptDialog(bookingData);
      // Call the custom notification
      CustomNotificationClass.MahekCustomNotification(
        context,
        "Booking Status", // Title of the notification
        "You can see your booking details in My Booking", // Description of the notification
        MyBooking(), // Widget to navigate to when tapped
        logoIcon: Icons.info, // Optional custom icon
      );
      return bookingData;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving booking: $e", toastLength: Toast.LENGTH_SHORT);
      return null;
    }
  }

  Future<void> _postCarRentalNotification() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('Users').doc(userId).collection('Notification').add({
          'title': 'Car Rental Successful!',
          'description': 'Thank you for choosing us! Your ${carData!.carName} has been rented successfully.',
          'time': Timestamp.now(),
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error sending notification: $e");
    }
  }

  void _showReceiptDialog(Map<String, dynamic> bookingData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.black.withOpacity(0.8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow)),
            const SizedBox(height: 16),
            Text(
              'Processing...',
              style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Car: ${bookingData['carName']?.length > 20 ? '${bookingData['carName']?.substring(0, 17)}...' : bookingData['carName'] ?? 'Not Found'}',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Seats: ${bookingData['seats'] ?? 'Not Found'}',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
            Text(
              'Total: ₹${(bookingData['totalPrice'] ?? 0).toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    // Navigate to BookingInformation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close the dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingInformation(recentBooking: bookingData),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Your Booking", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: carData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationCard(),
              const SizedBox(height: 10),
              _buildSubscriptionOptions(),
              const SizedBox(height: 10),
              _buildFuelAndSeats(),
              const SizedBox(height: 10),
              _buildUserDetailsCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomCard(),
    );
  }

  Widget _buildLocationCard() => Card(
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Trip Details", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 8),
          _buildLocationRow("From", widget.fromAddress, widget.pickUpDateTime),
          const SizedBox(height: 8),
          _buildLocationRow("To", widget.toAddress, widget.returnDateTime),
        ],
      ),
    ),
  );

  Widget _buildLocationRow(String label, String address, DateTime dateTime) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Text(address.length > 25 ? "${address.substring(0, 22)}..." : address, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
      Text(DateFormat('d MMM, HH:mm').format(dateTime), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blueAccent)),
    ],
  );

  Widget _buildSubscriptionOptions() => Card(
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Subscription Plans", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSubscriptionButton('BASIC', Colors.green, carData!.basicPrice.toDouble()),
              _buildSubscriptionButton('PLUS', Colors.orange, carData!.plusPrice.toDouble()),
              _buildSubscriptionButton('MAX', Colors.red, carData!.maxPrice.toDouble()),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildSubscriptionButton(String plan, Color color, double price) {
    final isSelected = selectedSubscription == plan;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubscription = plan;
          _calculatePrice(selectedSeats, selectedSubscription);
        });
        Fluttertoast.showToast(msg: "$plan plan selected!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.grey, width: 2),
        ),
        child: Column(
          children: [
            Text(plan, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
            Text('₹${price.toStringAsFixed(2)}/km', style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.black : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelAndSeats() => Card(
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSpecCard(Icons.local_gas_station, 'Fuel', carData!.fuelType, Colors.blueAccent),
          _buildSeatDropdown(),
        ],
      ),
    ),
  );

  Widget _buildSpecCard(IconData icon, String title, String value, Color color) => Container(
    width: 120,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
        Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );

  Widget _buildSeatDropdown() => Container(
    width: 150,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: selectedSeats == null ? Colors.grey[200] : Colors.blueAccent.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: selectedSeats == null ? Colors.grey : Colors.blueAccent),
    ),
    child: Column(
      children: [
        Icon(Icons.chair, color: selectedSeats == null ? Colors.black54 : Colors.blueAccent, size: 24),
        Text('Seats', style: GoogleFonts.poppins(fontSize: 12, color: selectedSeats == null ? Colors.grey[700] : Colors.blueAccent)),
        DropdownButton<String>(
          value: selectedSeats,
          hint: Text('Select', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          items: List.generate(carData!.noOfSeats, (index) => DropdownMenuItem<String>(value: (index + 1).toString(), child: Text('${index + 1} Seats', style: GoogleFonts.poppins(fontSize: 14)))),
          onChanged: (value) => setState(() {
            selectedSeats = value;
            _calculatePrice(selectedSeats, selectedSubscription);
          }),
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          icon: Icon(Icons.arrow_drop_down, color: selectedSeats == null ? Colors.black54 : Colors.blueAccent),
          underline: const SizedBox(),
        ),
      ],
    ),
  );

  Widget _buildUserDetailsCard() => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    future: _firestore.collection('Users').doc(FirebaseAuth.instance.currentUser?.uid).get(),
    builder: (context, snapshot) {
      final name = snapshot.data?.data()?['name'] ?? 'Not Found';
      final email = snapshot.data?.data()?['email'] ?? 'Not Found';
      final mobileNumber = snapshot.data?.data()?['mobile_number'] ?? 'Not Found';
      final city = snapshot.data?.data()?['city'] ?? 'Not Found';
      final state = snapshot.data?.data()?['state'] ?? 'Not Found';
      final country = snapshot.data?.data()?['country'] ?? 'Not Found';
      final licenseNo = snapshot.data?.data()?['license_no'] ?? 'Not Found';
      final pinCode = snapshot.data?.data()?['pin_code'] ?? 'Not Found';

      if (snapshot.hasError) {
        Fluttertoast.showToast(msg: "Error fetching user data: ${snapshot.error}");
      }

      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Details", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 8),
              _buildDetailRow("Name", name),
              _buildDetailRow("Email", email),
              _buildDetailRow("Mobile Number", mobileNumber),
              _buildDetailRow("City", city),
              _buildDetailRow("State", state),
              _buildDetailRow("Country", country),
              _buildDetailRow("License No", licenseNo),
              _buildDetailRow("Pin Code", pinCode),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
      ],
    ),
  );

  Widget _buildBottomCard() {
    final isButtonEnabled = isChecked && selectedSubscription != null && selectedSeats != null;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 5, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (value) => setState(() => isChecked = value ?? false),
                checkColor: Colors.white,
                activeColor: Colors.green,
              ),
              GestureDetector(
                onTap: () {
                  setState(() => isChecked = !isChecked);
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  Policy()));
                },
                child: Text('Terms and Conditions', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent, decoration: TextDecoration.underline)),
              ),
            ],
          ),
          if (_errorMessage case String message?) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(message, style: const TextStyle(color: Colors.red))),
          const Divider(),
          const SizedBox(height: 2),
          Text("Booking Summary", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 8),
          _buildSummaryRow("Distance", "${widget.coverDistance.toStringAsFixed(1)} km"),
          _buildSummaryRow("Subscription", selectedSubscription ?? 'Not selected'),
          _buildSummaryRow("Seats", selectedSeats ?? 'Not selected'),
          const Divider(color: Colors.grey, thickness: 1),
          _buildSummaryRow("Total", "₹${calculatedPrice.toStringAsFixed(2)}", isTotal: true),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${calculatedPrice.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
              ElevatedButton(
                onPressed: isButtonEnabled ? () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow))),
                  );
                  await Future.delayed(const Duration(seconds: 1));
                  _openRazorpay();
                } : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5),
                child: Text('Book Now', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, color: isTotal ? Colors.black : Colors.grey[700])),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, color: isTotal ? Colors.green[700] : Colors.grey[700])),
      ],
    ),
  );
}