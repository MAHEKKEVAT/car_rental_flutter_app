import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserBookingDetailsPage extends StatefulWidget {
  final DocumentReference documentReference;

  const UserBookingDetailsPage({super.key, required this.documentReference});

  @override
  _UserBookingDetailsPageState createState() => _UserBookingDetailsPageState();
}

class _UserBookingDetailsPageState extends State<UserBookingDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _bookingData;
  bool _hasInternet = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final connectivityResult = result.isNotEmpty ? result.first : ConnectivityResult.none;
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _hasInternet = false;
        });
      } else {
        setState(() {
          _hasInternet = true;
          if (_isLoading && _bookingData == null) _fetchBookingData();
        });
      }
    });
    _checkInternetConnection();
    _fetchBookingData();
    print('Fetching data for documentReference: ${widget.documentReference.path}');
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        _hasInternet = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBookingData() async {
    if (!_hasInternet) return;

    try {
      final docSnapshot = await widget.documentReference.get();
      if (docSnapshot.exists) {
        setState(() {
          _bookingData = docSnapshot.data() as Map<String, dynamic>;
          _isLoading = false;
        });
        print('Fetched booking data: $_bookingData');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No document found at path: ${widget.documentReference.path}');
      }
    } catch (e) {
      print('Error fetching booking: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptBooking() async {
    if (!_hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      await widget.documentReference.update({'status': 'accepted'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking accepted!', style: GoogleFonts.poppins()), backgroundColor: Colors.green),
      );
      await _fetchBookingData();
    } catch (e) {
      print('Error accepting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept booking', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectBooking() async {
    if (!_hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      await widget.documentReference.update({'status': 'rejected'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking rejected!', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
      );
      await _fetchBookingData();
    } catch (e) {
      print('Error rejecting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject booking', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
      );
    }
  }

  void _showConfirmationDialog({required String action, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Confirm $action',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to $action this booking?',
            style: GoogleFonts.poppins(
              color: Colors.grey[300],
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.yellow,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                action,
                style: GoogleFonts.poppins(
                  color: action == 'Accept' ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Not provided';
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/car.png', fit: BoxFit.cover),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    ),
                  )
                      : _hasInternet && _bookingData == null
                      ? Center(
                    child: Text(
                      'Booking not found',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                    ),
                  )
                      : !_hasInternet
                      ? Center(
                    child: Text(
                      'No internet connection',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                    ),
                  )
                      : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Booking Details',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Card(
                          color: Colors.grey[800],
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Car Details',
                                  style: GoogleFonts.poppins(
                                    color: Colors.yellow,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: _bookingData!['carImage1'] ?? 'https://via.placeholder.com/300x150',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Center(
                                      child: Icon(Icons.directions_car, color: Colors.grey, size: 100),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(Icons.directions_car, 'Car Name', _bookingData!['carName'] ?? 'Not provided'),
                                _buildDetailRow(Icons.event_seat, 'Seats', _bookingData!['seats']?.toString() ?? 'Not provided'),
                                _buildDetailRow(Icons.subscriptions, 'Subscription', _bookingData!['subscription'] ?? 'Not provided'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          color: Colors.grey[800],
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Details',
                                  style: GoogleFonts.poppins(
                                    color: Colors.yellow,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(Icons.info, 'Status', _bookingData!['status'] ?? 'Not provided', isStatus: true),
                                _buildDetailRow(Icons.attach_money, 'Total Price', '\$${_bookingData!['totalPrice']?.toString() ?? 'Not provided'}', isPrice: true),
                                _buildDetailRow(Icons.location_on, 'Pickup Location', _bookingData!['fromLocation'] ?? 'Not provided'),
                                _buildDetailRow(Icons.place, 'Pickup Address', _bookingData!['fromAddress'] ?? 'Not provided'),
                                if (_bookingData!['toLocation'] != null)
                                  _buildDetailRow(Icons.location_on, 'Dropoff Location', _bookingData!['toLocation']),
                                if (_bookingData!['toAddress'] != null)
                                  _buildDetailRow(Icons.place, 'Dropoff Address', _bookingData!['toAddress']),
                                _buildDetailRow(Icons.access_time, 'Pickup Time', _formatTimestamp(_bookingData!['pickUpDateTime'] as Timestamp?)),
                                if (_bookingData!['returnDateTime'] != null)
                                  _buildDetailRow(Icons.access_time, 'Return Time', _formatTimestamp(_bookingData!['returnDateTime'] as Timestamp?)),
                                if (_bookingData!['distance'] != null)
                                  _buildDetailRow(Icons.directions, 'Distance', '${_bookingData!['distance']?.toString() ?? '0'} km'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          color: Colors.grey[800],
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User Details',
                                  style: GoogleFonts.poppins(
                                    color: Colors.yellow,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailRow(Icons.person, 'Name', _bookingData!['userName'] ?? 'Not provided'),
                                _buildDetailRow(Icons.email, 'Email', _bookingData!['userEmail'] ?? 'Not provided'),
                                _buildDetailRow(Icons.phone, 'Mobile', _bookingData!['userMobile'] ?? 'Not provided'),
                                _buildDetailRow(Icons.card_membership, 'License', _bookingData!['userLicense'] ?? 'Not provided'),
                                _buildDetailRow(Icons.location_city, 'City', _bookingData!['userCity'] ?? 'Not provided'),
                                _buildDetailRow(Icons.map, 'State', _bookingData!['userState'] ?? 'Not provided'),
                                _buildDetailRow(Icons.local_post_office, 'Pin Code', _bookingData!['userPinCode'] ?? 'Not provided'),
                                _buildDetailRow(Icons.public, 'Country', _bookingData!['userCountry'] ?? 'Not provided'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showConfirmationDialog(
                          action: 'Accept',
                          onConfirm: _acceptBooking,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showConfirmationDialog(
                          action: 'Reject',
                          onConfirm: _rejectBooking,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Reject',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isPrice = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.yellow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                isStatus
                    ? Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: value.toLowerCase() == 'accepted'
                        ? Colors.green
                        : value.toLowerCase() == 'rejected'
                        ? Colors.red
                        : Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    : isPrice
                    ? Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.yellow[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    : Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}