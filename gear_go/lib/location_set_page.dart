import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'car_data_model.dart';
import 'pay_booking.dart';

class LocationSetPage extends StatefulWidget {
  final String documentId;

  const LocationSetPage({super.key, required this.documentId});

  @override
  State<LocationSetPage> createState() => _LocationSetPageState();
}

class _LocationSetPageState extends State<LocationSetPage> {
  String fromLocation = "Select From Location";
  String toLocation = "Select To Location";
  String? fromAddress;
  String? toAddress;
  bool useCurrentLocation = false;
  String selectedRentType = "Self-Driver";
  DateTime pickUpDate = DateTime.now();
  DateTime returnDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay pickUpTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay returnTime = const TimeOfDay(hour: 10, minute: 0);
  double distance = 0.0;
  LatLng? fromLatLng;
  LatLng? toLatLng;
  late MapController mapController;
  CarDataModel? carData;

  Future<void> _fetchCarData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('CarData')
          .doc(widget.documentId)
          .get();
      if (doc.exists) {
        setState(() {
          carData = CarDataModel.fromJson(doc.data() as Map<String, dynamic>, widget.documentId);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching car data: $e", toastLength: Toast.LENGTH_SHORT);
    }
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _fetchCarData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationDialog(context, true);
    });
  }

  String _truncateAddress(String? address) {
    if (address == null || address.isEmpty) return "Select Location";
    return address.length > 25 ? "${address.substring(0, 22)}..." : address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Book Your Car",
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: carData == null
          ? Center(child: CircularProgressIndicator(color: Colors.blue[700]))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCarInfoCard(),
                    SizedBox(height: 16),
                    _buildLocationSection(),
                    SizedBox(height: 16),
                    _buildRentTypeSection(),
                    SizedBox(height: 16),
                    _buildDateTimeSection(),
                  ],
                ),
              ),
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildCarInfoCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Colors.blue[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  carData!.carImage1.isNotEmpty ? carData!.carImage1 : 'https://via.placeholder.com/150',
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.red),
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    carData!.carName,
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                  ),
                  Text(
                    carData!.carBrand,
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[800]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Your Locations",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        SizedBox(height: 12),
        _buildLocationField("From", fromAddress, true),
        SizedBox(height: 12),
        _buildLocationField("To", toAddress, false),
      ],
    );
  }

  Widget _buildLocationField(String label, String? address, bool isFrom) {
    return GestureDetector(
      onTap: () => _showLocationDialog(context, isFrom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          border: Border.all(color: Colors.blue[200]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(isFrom ? Icons.location_on_outlined : Icons.flag_outlined, color: Colors.blue[600], size: 20),
                SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
              ],
            ),
            Flexible(
              child: Text(
                _truncateAddress(address),
                style: GoogleFonts.poppins(fontSize: 14, color: address == null ? Colors.grey[600] : Colors.grey[800]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildRentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Rent Type",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Center(
            child: Text(
              selectedRentType,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pick-Up & Return",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDateTimeField("Pick-Up Date", pickUpDate, pickUpTime, true)),
            SizedBox(width: 12),
            Expanded(child: _buildDateTimeField("Return Date", returnDate, returnTime, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeField(String label, DateTime date, TimeOfDay time, bool isPickUp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: isPickUp ? pickUpDate : returnDate,
              firstDate: isPickUp ? DateTime.now() : pickUpDate,
              lastDate: DateTime(2026),
            );
            if (picked != null) {
              setState(() => isPickUp ? pickUpDate = picked : returnDate = picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM, yyyy').format(date),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                ),
                Icon(Icons.calendar_today, color: Colors.blue[700], size: 20),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            TimeOfDay? picked = await showTimePicker(context: context, initialTime: isPickUp ? pickUpTime : returnTime);
            if (picked != null) {
              DateTime now = DateTime.now();
              DateTime selected = DateTime(date.year, date.month, date.day, picked.hour, picked.minute);
              if (selected.isBefore(now.add(Duration(hours: 1)))) {
                Fluttertoast.showToast(msg: "$label cannot be in the past!", toastLength: Toast.LENGTH_SHORT);
                return;
              }
              setState(() => isPickUp ? pickUpTime = picked : returnTime = picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                ),
                Icon(Icons.access_time, color: Colors.blue[700], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (fromAddress == null || toAddress == null) {
            Fluttertoast.showToast(
              msg: "Please select both From and To locations!",
              toastLength: Toast.LENGTH_SHORT,
            );
            return;
          }
          DateTime pickUpDateTime = DateTime(
            pickUpDate.year,
            pickUpDate.month,
            pickUpDate.day,
            pickUpTime.hour,
            pickUpTime.minute,
          );
          DateTime returnDateTime = DateTime(
            returnDate.year,
            returnDate.month,
            returnDate.day,
            returnTime.hour,
            returnTime.minute,
          );
          if (pickUpDateTime.isAfter(returnDateTime)) {
            Fluttertoast.showToast(
              msg: "Pick-up time must be before return time!",
              toastLength: Toast.LENGTH_SHORT,
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PayBooking(
                documentId: widget.documentId,
                fromLocation: fromLocation,
                toLocation: toLocation,
                fromAddress: fromAddress!,
                toAddress: toAddress!,
                pickUpDateTime: pickUpDateTime,
                returnDateTime: returnDateTime,
                coverDistance: distance,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: Text(
          "CONTINUE (${distance.toStringAsFixed(1)} km)",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  Future<void> _showLocationDialog(BuildContext context, bool isFrom) async {
    LatLng initialPosition = LatLng(21.124857, 73.112610);
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  isFrom ? "Select Pick-Up Location" : "Select Drop-Off Location",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    var status = await Permission.location.request();
                    if (status.isGranted) {
                      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                      try {
                        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
                        String address = placemarks.isNotEmpty
                            ? "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}"
                            : "Current Location";
                        setState(() {
                          if (isFrom) {
                            fromAddress = address;
                            fromLatLng = LatLng(position.latitude, position.longitude);
                            fromLocation = _truncateAddress(address);
                          } else {
                            toAddress = address;
                            toLatLng = LatLng(position.latitude, position.longitude);
                            toLocation = _truncateAddress(address);
                          }
                          _calculateDistance();
                        });
                        Fluttertoast.showToast(msg: "Current location set!", toastLength: Toast.LENGTH_SHORT);
                      } catch (e) {
                        print("Error fetching address from current location: $e");
                        Fluttertoast.showToast(msg: "Error fetching address: $e", toastLength: Toast.LENGTH_LONG);
                        setState(() {
                          if (isFrom) {
                            fromAddress = "Current Location (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})";
                            fromLatLng = LatLng(position.latitude, position.longitude);
                            fromLocation = _truncateAddress(fromAddress);
                          } else {
                            toAddress = "Current Location (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})";
                            toLatLng = LatLng(position.latitude, position.longitude);
                            toLocation = _truncateAddress(toAddress);
                          }
                          _calculateDistance();
                        });
                      }
                      Navigator.pop(context);
                    } else {
                      Fluttertoast.showToast(msg: "Location permission denied!", toastLength: Toast.LENGTH_SHORT);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.my_location, color: Colors.blue[700], size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Use Current Location",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue[900]),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: initialPosition,
                          initialZoom: 12.0,
                          minZoom: 10.0,
                          maxZoom: 18.0,
                          onTap: (tapPosition, point) async {
                            try {
                              List<Placemark> placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
                              String address = placemarks.isNotEmpty
                                  ? "${placemarks[0].street}, ${placemarks[0].locality}, ${placemarks[0].country}"
                                  : "Unknown Location (${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})";
                              setState(() {
                                if (isFrom) {
                                  fromAddress = address;
                                  fromLatLng = point;
                                  fromLocation = _truncateAddress(address);
                                } else {
                                  toAddress = address;
                                  toLatLng = point;
                                  toLocation = _truncateAddress(address);
                                }
                                _calculateDistance();
                              });
                              Fluttertoast.showToast(msg: "Location selected!", toastLength: Toast.LENGTH_SHORT);
                            } catch (e) {
                              print("Error fetching address from map tap: $e");
                              Fluttertoast.showToast(msg: "Error fetching address: $e", toastLength: Toast.LENGTH_LONG);
                              String fallbackAddress = "Location (${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})";
                              setState(() {
                                if (isFrom) {
                                  fromAddress = fallbackAddress;
                                  fromLatLng = point;
                                  fromLocation = _truncateAddress(fallbackAddress);
                                } else {
                                  toAddress = fallbackAddress;
                                  toLatLng = point;
                                  toLocation = _truncateAddress(fallbackAddress);
                                }
                                _calculateDistance();
                              });
                            }
                            Navigator.pop(context);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              if (fromLatLng != null)
                                Marker(
                                  point: fromLatLng!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_pin, color: Colors.blue[700], size: 40),
                                ),
                              if (toLatLng != null)
                                Marker(
                                  point: toLatLng!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.location_pin, color: Colors.redAccent, size: 40),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Close",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _calculateDistance() {
    if (fromLatLng != null && toLatLng != null) {
      final Distance distanceCalculator = Distance();
      setState(() {
        distance = distanceCalculator.as(LengthUnit.Kilometer, fromLatLng!, toLatLng!);
      });
    }
  }
}