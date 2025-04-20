import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _carNameController = TextEditingController();
  final _chassisNoController = TextEditingController();
  final _engineNoController = TextEditingController();
  final _feature1Controller = TextEditingController();
  final _feature2Controller = TextEditingController();
  final _feature3Controller = TextEditingController();
  final _feature4Controller = TextEditingController();
  final _feature5Controller = TextEditingController();
  final _feature6Controller = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _noOfSeatsController = TextEditingController();
  final _subscriptionController = TextEditingController();
  List<String?> _images = List.filled(4, null); // Reduced to 4 images as per requirement
  bool _isSaving = false;
  String? _carCategory; // For car category dropdown
  List<String> _carBrands = []; // To store brands from Firestore

  @override
  void initState() {
    super.initState();
    _fetchCarBrands(); // Fetch brands from Firestore
  }

  // Fetch car brands from Firestore 'Brands' collection
  Future<void> _fetchCarBrands() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Brands').get();
      setState(() {
        _carBrands = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching brands: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
      );
    }
  }

  // Simulate image upload
  void _uploadImage(int index) {
    setState(() {
      _images[index] = 'https://via.placeholder.com/150'; // Mock image URL
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image ${index + 1} uploaded!', style: GoogleFonts.poppins()), backgroundColor: Colors.green),
    );
  }

  // Save car details to Firestore
  Future<void> _saveCar() async {
    if (_formKey.currentState!.validate() && _images.every((img) => img != null)) {
      setState(() => _isSaving = true);
      try {
        await FirebaseFirestore.instance.collection('CarData').add({
          'car_name': _carNameController.text,
          'car_category': _carCategory,
          'chassis_no': _chassisNoController.text,
          'engine_no': _engineNoController.text,
          'features': [_feature1Controller.text, _feature2Controller.text, _feature3Controller.text, _feature4Controller.text, _feature5Controller.text, _feature6Controller.text],
          'fuel_type': _fuelTypeController.text,
          'no_of_seats': int.tryParse(_noOfSeatsController.text) ?? 0,
          'subscription': _subscriptionController.text,
          'images': _images,
          'created_at': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car added successfully!', style: GoogleFonts.poppins()), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isSaving = false);
      }
    } else if (_images.any((img) => img == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload all 4 images!', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _carNameController.dispose();
    _chassisNoController.dispose();
    _engineNoController.dispose();
    _feature1Controller.dispose();
    _feature2Controller.dispose();
    _feature3Controller.dispose();
    _feature4Controller.dispose();
    _feature5Controller.dispose();
    _feature6Controller.dispose();
    _fuelTypeController.dispose();
    _noOfSeatsController.dispose();
    _subscriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.3)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Opacity(
                opacity: 0.25,
                child: Image.asset('assets/images/car.png', fit: BoxFit.cover),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New Car', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Enter car details and upload images', style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 16)),
                    const SizedBox(height: 20),
                    // Image Upload Section
                    Text('Car Images (4 required)', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _uploadImage(index),
                            child: Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                              ),
                              child: _images[index] == null
                                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.add_photo_alternate, color: Colors.grey[500], size: 40),
                                Text('Add', style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
                              ])
                                  : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(_images[index]!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Divider(color: Colors.grey[800], thickness: 1),
                    const SizedBox(height: 20),
                    // Car Card
                    Text('Car Details', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Card(
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _carNameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Car Name (e.g., Honda City)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.directions_car, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter car name';
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) return 'Only alphanumeric characters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}), // Trigger validation on change
                            ),
                            if (_carNameController.text.isNotEmpty && _formKey.currentState?.validate() == false)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Only alphanumeric characters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: _carCategory,
                              hint: Text('Select Car Category', style: GoogleFonts.poppins(color: Colors.grey[500])),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.category, color: Colors.yellow),
                              ),
                              items: _carBrands.map((brand) {
                                return DropdownMenuItem<String>(
                                  value: brand,
                                  child: Text(brand, style: GoogleFonts.poppins(color: Colors.black,fontSize: 19)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _carCategory = value);
                              },
                              validator: (value) => value == null ? 'Please select a car category' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _chassisNoController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Chassis No (17 chars, Numeric & Caps)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.build, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter chassis number';
                                if (value.length != 17) return 'Chassis must be exactly 17 characters';
                                if (!RegExp(r'^[0-9A-Z]+$').hasMatch(value)) return 'Only numeric and capital letters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if (_chassisNoController.text.length != 17 && _chassisNoController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Chassis must be exactly 17 characters',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            if (!RegExp(r'^[0-9A-Z]+$').hasMatch(_chassisNoController.text) && _chassisNoController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Only numeric and capital letters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _engineNoController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Engine No (e.g., L13Z123456789)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.engineering, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter engine number';
                                if (value.length < 8 || value.length > 12) return 'Engine number must be 8-12 characters';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if ((_engineNoController.text.length < 8 || _engineNoController.text.length > 12) && _engineNoController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Engine number must be 8-12 characters',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Feature Card
                    Card(
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Features', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _feature1Controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Feature 1 (e.g., LED Headlights)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.star, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value != null && value.length > 15) return 'Max 15 characters allowed';
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value ?? '')) return 'Only alphanumeric characters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if (_feature1Controller.text.length > 15 && _feature1Controller.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 15 characters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _feature2Controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Feature 2 (e.g., 7-inch Touchscreen)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.star, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value != null && value.length > 15) return 'Max 15 characters allowed';
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value ?? '')) return 'Only alphanumeric characters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if (_feature2Controller.text.length > 15 && _feature2Controller.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 15 characters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _feature3Controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Feature 3 (e.g., Wireless Apple CarPlay)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.star, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value != null && value.length > 15) return 'Max 15 characters allowed';
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value ?? '')) return 'Only alphanumeric characters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if (_feature3Controller.text.length > 15 && _feature3Controller.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 15 characters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _feature4Controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Feature 4 (e.g., Rear AC Vents)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.star, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value != null && value.length > 15) return 'Max 15 characters allowed';
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value ?? '')) return 'Only alphanumeric characters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if (_feature4Controller.text.length > 15 && _feature4Controller.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 15 characters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _feature5Controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Feature 5 (e.g., Alloy Wheels)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.star, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value != null && value.length > 15) return 'Max 15 characters allowed';
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value ?? '')) return 'Only alphanumeric characters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if (_feature5Controller.text.length > 15 && _feature5Controller.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 15 characters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _feature6Controller,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Feature 6 (e.g., Smart Key Access)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.star, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              validator: (value) {
                                if (value != null && value.length > 15) return 'Max 15 characters allowed';
                                if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value ?? '')) return 'Only alphanumeric characters allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if (_feature6Controller.text.length > 15 && _feature6Controller.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 15 characters allowed',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Fuel Type Card
                    Card(
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fuel Type', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              value: _fuelTypeController.text.isNotEmpty ? _fuelTypeController.text : null,
                              hint: Text('Select Fuel Type', style: GoogleFonts.poppins(color: Colors.grey[500])),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.local_gas_station, color: Colors.yellow),
                              ),
                              items: ['Petrol', 'CNG', 'Diesel'].map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type, style: GoogleFonts.poppins(color: Colors.black,fontSize: 19)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _fuelTypeController.text = value ?? '');
                              },
                              validator: (value) => value == null ? 'Please select a fuel type' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Subscription Card
                    Card(
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subscription', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _subscriptionController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'Plan Price (e.g., 1000)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.subscriptions, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter subscription price';
                                if (int.tryParse(value) == null) return 'Only numeric values allowed';
                                if (value.length > 4) return 'Max 4 digits allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if ((_subscriptionController.text.length > 4 || int.tryParse(_subscriptionController.text) == null) && _subscriptionController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 4 digits and numeric only',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Seat Card
                    Card(
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seats', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _noOfSeatsController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                hintText: 'No of Seats (e.g., 5)',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.event_seat, color: Colors.yellow),
                              ),
                              style: GoogleFonts.poppins(color: Colors.white),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter number of seats';
                                if (int.tryParse(value) == null) return 'Only numeric values allowed';
                                if (value.length > 2) return 'Max 2 digits allowed';
                                return null;
                              },
                              onChanged: (value) => setState(() {}),
                            ),
                            if ((_noOfSeatsController.text.length > 2 || int.tryParse(_noOfSeatsController.text) == null) && _noOfSeatsController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 14.0, top: 4),
                                child: Text(
                                  'Max 2 digits and numeric only',
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: _isSaving || _images.any((img) => img == null) ? null : _saveCar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: _isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : Text('Save', style: GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}