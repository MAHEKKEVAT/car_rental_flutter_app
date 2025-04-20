import 'dart:io';
import 'package:car_rental_admin/authentication/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class SetLocationPage extends StatefulWidget {
  final String userId;

  const SetLocationPage({super.key, required this.userId});

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {
  final _locationController = TextEditingController();
  LatLng? _selectedLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionAndSetLocation() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location permissions are permanently denied, please enable them in settings');
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _selectedLocation = LatLng(position.latitude, position.longitude);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _locationController.text = '${placemark.locality}, ${placemark.country}';
      }
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error getting location: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectLocationOnMap() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final initialLocation = const LatLng(21.0696819, 73.1342103); // Default location
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Location Selection Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        body: FlutterMap(
          options: MapOptions(
            initialCenter: _selectedLocation ?? initialLocation,
            initialZoom: 12.0,
            onTap: (tapPosition, point) async {
              _selectedLocation = point;
              final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
              if (placemarks.isNotEmpty) {
                final placemark = placemarks.first;
                setState(() {
                  _locationController.text = '${placemark.locality}, ${placemark.country}';
                });
              }
              Navigator.pop(context); // Close the map after selection
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
    setState(() {});
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveLocationAndProceed() async {
    if (_selectedLocation == null || _locationController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select a location first');
      return;
    }
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('CarAdmin').doc(widget.userId).update({
        'selectedLocation': _locationController.text,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error saving location: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    // Show warning dialog
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Account Created Successfully!',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your account is ready! If you go back now, the app will close, and you can log in later with your credentials. Do you want to proceed?',
          style: GoogleFonts.poppins(
            color: Colors.grey[300],
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Stay on page
            child: Text(
              'No',
              style: GoogleFonts.poppins(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Allow back navigation
              exit(0); // Close the app
            },
            child: Text(
              'Yes',
              style: GoogleFonts.poppins(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D), Color(0xFF404040)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/car.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 100,
                        color: Colors.yellow,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Set Your Location',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.yellow.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _selectLocationOnMap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 15,
                          minimumSize: const Size(300, 60),
                        ),
                        child: Text(
                          'Set a Location',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _checkPermissionAndSetLocation,
                        child: Text(
                          'Use Current Location',
                          style: GoogleFonts.poppins(
                            color: Colors.yellow,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 320,
                        child: ElevatedButton(
                          onPressed: _isLoading || _selectedLocation == null || _locationController.text.isEmpty
                              ? null
                              : _saveLocationAndProceed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedLocation != null && _locationController.text.isNotEmpty
                                ? Colors.yellow[700]
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 15,
                            minimumSize: const Size(300, 60),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.yellow)
                              : Text(
                            'Get Started',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Location',
          style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 20),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _locationController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black,
            hintText: 'No location selected',
            hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 18),
            prefixIcon: const Icon(Icons.map, color: Colors.yellow),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey[700]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.yellow, width: 2.5),
            ),
          ),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }
}