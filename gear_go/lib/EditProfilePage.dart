import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController(); // Re-added
  String? _city;
  String? _country = "India";

  bool _isLoading = true;
  File? _profileImage;
  String? _profileImageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late appwrite.Client client;
  late appwrite.Storage storage;

  final List<String> _cities = ['BILIMORA', 'BARDOLI', 'BABEN', 'SURAT', 'NAVSARI'];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    client = appwrite.Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('67e8384a0024f79666ba');
    storage = appwrite.Storage(client);
    Fluttertoast.showToast(msg: "Appwrite connected successfully!");
    _loadUserData();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted && await Permission.camera.request().isGranted) return;
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('Users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            _nameController.text = userDoc.data()!['name'] ?? '';
            _bioController.text = userDoc.data()!['bio'] ?? '';
            _emailController.text = user.email ?? '';
            _city = userDoc.data()!['city'] ?? '';
            _country = userDoc.data()!['country'] ?? 'India';
            _mobileNumberController.text = userDoc.data()!['mobile_number'] ?? '';
            _pinCodeController.text = userDoc.data()!['pin_code'] ?? '';
            _licenseNoController.text = userDoc.data()!['license_no'] ?? ''; // Loaded license number
            _profileImageUrl = userDoc.data()!['profile_image'] ?? '';
          });
        } else {
          setState(() {
            _nameController.text = '';
            _bioController.text = '';
            _emailController.text = user.email ?? '';
            _city = null;
            _country = 'India';
            _mobileNumberController.text = '';
            _pinCodeController.text = '';
            _licenseNoController.text = ''; // Default for missing license
            _profileImageUrl = null;
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(toolbarTitle: 'Crop Image', toolbarColor: Colors.blue, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: false),
            IOSUiSettings(title: 'Crop Image'),
          ],
        );
        if (croppedFile != null) {
          setState(() => _profileImage = File(croppedFile.path));
          Fluttertoast.showToast(msg: "Image selected and cropped!");
        }
      } else {
        Fluttertoast.showToast(msg: "No image selected");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to pick image: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      if (!(await Permission.camera.isGranted)) {
        if (await Permission.camera.request().isDenied) {
          Fluttertoast.showToast(msg: "Camera permission denied.");
          return;
        }
      }
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(toolbarTitle: 'Crop Image', toolbarColor: Colors.blue, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: false),
            IOSUiSettings(title: 'Crop Image'),
          ],
        );
        if (croppedFile != null) {
          setState(() => _profileImage = File(croppedFile.path));
          Fluttertoast.showToast(msg: "Photo taken and cropped!");
        }
      } else {
        Fluttertoast.showToast(msg: "No photo taken");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to take photo: $e");
    }
  }

  Future<void> _uploadImage(File file) async {
    setState(() => _isLoading = true);
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final result = await storage.createFile(bucketId: '67ec1162000a2853d3f7', fileId: 'unique()', file: appwrite.InputFile(path: file.path));
        Fluttertoast.showToast(msg: "Bucket connected successfully!");
        String imageUrl = result.$id;
        await _firestore.collection('Users').doc(user.uid).update({
          'profile_image': 'https://cloud.appwrite.io/v1/storage/buckets/67ec1162000a2853d3f7/files/$imageUrl/view?project=67e8384a0024f79666ba',
        });
        Fluttertoast.showToast(msg: "Profile image updated successfully!");
        _postNotification();
      } catch (e) {
        print("Error uploading image: $e");
        Fluttertoast.showToast(msg: "Error updating image.");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      User? user = _auth.currentUser;
      if (user != null) {
        String name = _nameController.text.trim();
        String bio = _bioController.text.trim();
        String city = _city ?? '';
        String country = _country ?? 'India';
        String mobileNumber = _mobileNumberController.text.trim();
        String pinCode = _pinCodeController.text.trim();
        String licenseNo = _licenseNoController.text.trim(); // Added license number
        try {
          await _firestore.collection('Users').doc(user.uid).update({
            'name': name,
            'bio': bio,
            'city': city,
            'country': country,
            'mobile_number': mobileNumber,
            'pin_code': pinCode,
            'license_no': licenseNo, // Updated in Firestore
            'dateUpdated': DateTime.now(),
          });
          if (_profileImage != null) {
            await _uploadImage(_profileImage!);
          } else {
            Fluttertoast.showToast(msg: 'Profile updated successfully without image!');
            _postNotification();
          }
        } catch (e) {
          print("Error updating user data: $e");
          Fluttertoast.showToast(msg: "Error updating profile data.");
        } finally {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: "User not logged in.");
      }
    }
  }

  Future<void> _deleteImage() async {
    setState(() => _isLoading = true);
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('Users').doc(user.uid).update({'profile_image': FieldValue.delete()});
        Fluttertoast.showToast(msg: "Profile image deleted successfully!");
        setState(() {
          _profileImage = null;
          _profileImageUrl = null;
        });
      } catch (e) {
        print("Error deleting image: $e");
        Fluttertoast.showToast(msg: "Error deleting image.");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _postNotification() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      String title = "Profile Update!";
      String description = "You have updated your profile.";
      String time = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
      await _firestore.collection('Users').doc(userId).collection('Notification').add({'title': title, 'description': description, 'time': time});
    } catch (error) {
      Fluttertoast.showToast(msg: "Error: $error");
    }
  }

  void _showImageOptions() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 100, 100),
      items: [
        PopupMenuItem(child: Text('View Photo'), onTap: () => _profileImageUrl != null ? Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoView(imageProvider: NetworkImage(_profileImageUrl!)))) : Fluttertoast.showToast(msg: "No image to view.")),
        PopupMenuItem(child: Text('Change Photo'), onTap: _pickImage),
        PopupMenuItem(child: Text('Take Photo'), onTap: _takePhoto),
        PopupMenuItem(child: Text('Delete Photo'), onTap: _deleteImage),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        leading: Container(margin: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(30)), child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.blue[700]), onPressed: () => Navigator.pop(context))),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _showImageOptions,
                          child: Stack(alignment: Alignment.center, children: [
                            Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
                              child: CircleAvatar(radius: 60, backgroundColor: Colors.blue[100], backgroundImage: _profileImage != null ? FileImage(_profileImage!) : _profileImageUrl != null && _profileImageUrl!.isNotEmpty ? NetworkImage(_profileImageUrl!) : null, child: _profileImage == null && _profileImageUrl == null ? Icon(Icons.add_a_photo, size: 35, color: Colors.blue[700]) : null),
                            ),
                            Positioned(bottom: -10, right: -10, child: Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue[700], shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]), child: Icon(Icons.camera_alt, color: Colors.white, size: 22))),
                          ]),
                        ),
                      ),
                      SizedBox(height: 25),
                      Text('Personal Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                          labelText: 'Name',
                          hintText: _nameController.text.isEmpty ? 'Enter your name (A-Z, a-z only)' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Name is required';
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Name must contain only letters and spaces';
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                          labelText: 'Email',
                          hintText: _emailController.text.isEmpty ? 'Enter your email' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        ),
                        enabled: false,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.description, color: Colors.blue[700]),
                          labelText: 'Bio',
                          hintText: _bioController.text.isEmpty ? 'Tell us about yourself...' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text('Location', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _city,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_city, color: Colors.blue[700]),
                          labelText: 'City',
                          hintText: _city == null ? 'Select your city' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        ),
                        items: _cities.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => _city = newValue);
                        },
                        validator: (value) => value == null ? 'City is required' : null,
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _country,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.public, color: Colors.blue[700]),
                          labelText: 'Country',
                          hintText: _country == null ? 'Select your country' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        ),
                        items: ['India'].map((String country) {
                          return DropdownMenuItem<String>(
                            value: country,
                            child: Text(country, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => _country = newValue);
                        },
                        validator: (value) => value == null ? 'Country is required' : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _pinCodeController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.pin_drop, color: Colors.blue[700]),
                          labelText: 'Pin Code',
                          hintText: _pinCodeController.text.isEmpty ? 'Enter 6-digit pin code' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Pin code is required';
                          if (value.length != 6) return 'Pin code must be exactly 6 digits';
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      Text('Additional Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _licenseNoController, // Re-added field
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.card_membership, color: Colors.blue[700]),
                          labelText: 'License No',
                          hintText: _licenseNoController.text.isEmpty ? 'Enter your license number' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        ),
                        // Optional validation (e.g., non-empty or specific format)
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'License number is required';
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _mobileNumberController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone, color: Colors.blue[700]),
                          labelText: 'Mobile Number',
                          hintText: _mobileNumberController.text.isEmpty ? 'Enter 10-digit mobile number' : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[200]!, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 1),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Mobile number is required';
                          if (value.length != 10) return 'Mobile number must be exactly 10 digits';
                          return null;
                        },
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveChanges,
                          child: _isLoading
                              ? LoadingAnimationWidget.dotsTriangle(color: Colors.white, size: 30)
                              : Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Center(
                child: LoadingAnimationWidget.dotsTriangle(color: Colors.blue[700]!, size: 60),
              ),
          ],
        ),
      ),
    );
  }
}