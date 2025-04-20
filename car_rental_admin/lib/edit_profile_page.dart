import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  LatLng? _selectedLocation;
  bool _isLoading = true;
  bool _isSaveEnabled = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late appwrite.Client _client;
  late appwrite.Storage _storage;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _client = appwrite.Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('67e8384a0024f79666ba');
    _storage = appwrite.Storage(_client);
    _loadUserData();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.camera.request().isGranted) {
      return;
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    String? userId = _auth.currentUser?.uid ?? _firestore.collection('CarAdmin').doc().id;
    try {
      final doc = await _firestore.collection('CarAdmin').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _locationController.text = data['selectedLocation'] ?? '';
          _profileImageUrl = data['profileImage'] ?? '';
        });
      } else {
        Fluttertoast.showToast(msg: 'User data not found for ID: $userId');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
      _checkFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.yellow,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
            ),
            IOSUiSettings(title: 'Crop Image'),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _profileImage = File(croppedFile.path);
          });
          _checkFields();
          Fluttertoast.showToast(msg: "Image selected and cropped!");
        }
      } else {
        Fluttertoast.showToast(msg: "No image selected");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to pick image: $e");
    }
  }

  Future<void> _selectLocation() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final initialLocation = const LatLng(21.0696819, 73.1342103);
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Location Selection Dialog',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        body: FlutterMap(
          options: MapOptions(
            initialCenter: initialLocation,
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
              Navigator.pop(context);
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
    setState(() => _isLoading = false);
    _checkFields();
  }

  void _checkFields() {
    setState(() {
      _isSaveEnabled = _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _locationController.text.isNotEmpty;
    });
  }

  void _clearData() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _locationController.clear();
      _profileImage = null;
      _selectedLocation = null;
      _isSaveEnabled = false;
    });
  }

  Future<String?> _uploadImageToAppwrite(File file) async {
    try {
      final result = await _storage.createFile(
        bucketId: '67ec1162000a2853d3f7', // Replace with your Appwrite bucket ID
        fileId: 'unique',
        file: appwrite.InputFile.fromPath(path: file.path, filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'),
      );
      return 'https://cloud.appwrite.io/v1/storage/buckets/67ec1162000a2853d3f7/files/${result.$id}/view?project=67e8384a0024f79666ba';
    } catch (e) {
      print('Error uploading to Appwrite: $e');
      Fluttertoast.showToast(msg: 'Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && !_isLoading && _auth.currentUser != null) {
      setState(() => _isLoading = true);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            strokeWidth: 6.0,
          ),
        ),
      );

      try {
        String? imageUrl = _profileImageUrl;
        if (_profileImage != null) {
          imageUrl = await _uploadImageToAppwrite(_profileImage!);
          if (imageUrl == null) {
            Navigator.pop(context);
            setState(() => _isLoading = false);
            return;
          }
        }

        await _firestore.collection('CarAdmin').doc(_auth.currentUser!.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'selectedLocation': _locationController.text,
          'profileImage': imageUrl ?? '',
        }, SetOptions(merge: true));

        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Profile Updated successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 18,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Error saving data: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImageOptions() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(
          child: const Text('Change Photo'),
          onTap: _pickImage,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
          strokeWidth: 6.0,
        ),
      )
          : Stack(
        children: [
          // Background image covering full screen
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black), // Fallback with black background
              ),
            ),
          ),
          // Centered foreground content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title and Subtitle
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.yellow.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Manage your account details',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    // Profile Form Container
                    Container(
                      width: double.infinity, // Ensure it takes full width but centers content
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.yellow.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile Image
                              GestureDetector(
                                onTap: _showImageOptions,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.yellow,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                                          : null,
                                      child: _profileImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                                          ? const Icon(Icons.person, size: 50, color: Colors.black)
                                          : null,
                                    ),
                                    const Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.green,
                                        child: Icon(Icons.check, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Form Fields
                              _buildTextField('Full Name', _nameController, (value) {
                                if (value == null || value.isEmpty) return 'Please enter Full Name';
                                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Only alphabets are allowed';
                                return null;
                              }, hint: 'Enter your full name'),
                              _buildTextField('Email', _emailController, (value) {
                                if (value == null || value.isEmpty) return 'Please enter Email';
                                return null;
                              }, hint: 'Enter your email', enabled: false),
                              _buildTextField('Phone', _phoneController, (value) {
                                if (value == null || value.isEmpty) return 'Please enter Phone';
                                if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Enter exactly 10 digits';
                                return null;
                              }, hint: 'Enter your 10-digit phone number'),
                              GestureDetector(
                                onTap: _selectLocation,
                                child: AbsorbPointer(
                                  child: _buildTextField('Location', _locationController, (value) {
                                    if (value == null || value.isEmpty) return 'Please select Location';
                                    return null;
                                  }, hint: 'Tap to select location'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Save Changes Button
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: _isSaveEnabled && !_isLoading ? _saveChanges : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          strokeWidth: 3.0,
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save, color: Colors.black, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Clear Data Button
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: _clearData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.delete, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Clear Data',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                strokeWidth: 6.0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String? Function(String?) validator,
      {String? hint, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 16),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.yellow, width: 2),
          ),
        ),
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        enabled: enabled,
        validator: validator,
        onChanged: (_) => _checkFields(),
      ),
    );
  }
}