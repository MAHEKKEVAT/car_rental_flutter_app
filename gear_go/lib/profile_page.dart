import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditProfilePage.dart';
import 'FavouritesPage.dart';
import 'HelpPage.dart';
import 'MyBooking.dart';
import 'settings_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;
  String? profileImageUrl;
  String? bio;
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchUserData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
    });
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email;
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            userName = userDoc.data()!['name'];
            profileImageUrl = userDoc.data()!['profile_image'];
            bio = userDoc.data()!['bio'];
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: isLoading,
            child: AnimatedOpacity(
              opacity: isLoading ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.blue[100],
                                  child: CircleAvatar(
                                    radius: 38,
                                    backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                                        ? NetworkImage(profileImageUrl!)
                                        : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                                    child: profileImageUrl == null || profileImageUrl!.isEmpty
                                        ? Icon(Icons.person, color: Colors.blue[800], size: 40)
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName ?? 'Loading...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      userEmail ?? 'Loading...',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => EditProfilePage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                elevation: 4,
                              ),
                              child: Text(
                                'Edit Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Me',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              bio == null || bio!.isEmpty
                                  ? "I love sharing my car adventures! What’s your story?"
                                  : bio!,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildOptionTile(context, 'My Rentals', Icons.directions_car),
                          _buildOptionTile(context, 'Settings', Icons.settings),
                          _buildOptionTile(context, 'Help', Icons.help),
                          _buildOptionTile(context, 'Favourites', Icons.favorite),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.dotsTriangle(
                color: Colors.blue[700]!,
                size: 60,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue[700], size: 24),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[600], size: 18),
          onTap: () {
            if (title == 'Settings') {
              Navigator.push(context, CupertinoPageRoute(builder: (context) => SettingsPage()));
            }
            if (title == 'Help') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
            }
            if (title == 'My Rentals') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyBooking()));
            }
            if (title == 'Favourites') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavouritesPage()));
            }
          },
        ),
      ),
    );
  }
}