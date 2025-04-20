import 'package:flutter/material.dart';
import 'package:gear_go/MyBooking.dart';
import 'package:gear_go/notification_page.dart';
import 'package:gear_go/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'ChoosePage.dart';
import 'home_page_body.dart'; // Included for reference, adjust if needed

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  String? userImage;
  String? userEmail;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    CarListPage(selectedIndex: 0, pages: []), // Restored CarListPage as the first page
    MyBooking(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialUserData(); // Fetch initial data
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of PageController to prevent memory leaks
    super.dispose();
  }

  Future<void> _fetchInitialUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection('Users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userName = userDoc.data()!['name'];
          userEmail = user.email;
          userImage = userDoc.data()!['profile_image'];
        });
      } else {
        setState(() {
          userName = "User";
          userEmail = "Email not available";
          userImage = null;
        });
      }
    } else {
      setState(() {
        userName = "Guest";
        userEmail = "Email not available";
        userImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldExit = await showDialog(
          context: context,
          builder: (context) => ExitConfirmationDialog(),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          elevation: 0,
          title: Row(
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.location_on,
                      color: Colors.blue[800], size: 28),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('/search_filter');
                },
              ),
              SizedBox(width: 12),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseAuth.instance.currentUser != null
                    ? _firestore
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Loading...",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Guest",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data?['name'] ?? "User",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  _showUserProfile(context);
                },
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseAuth.instance.currentUser != null
                      ? _firestore
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person, color: Colors.blue[800], size: 28),
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                          child: Icon(Icons.person, color: Colors.blue[800], size: 28),
                        ),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final imageUrl = data?['profile_image'];
                    return CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? null
                            : Icon(Icons.person, color: Colors.blue[800], size: 28),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // Disable manual scrolling
          children: _pages,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.home, 0),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.directions_car, 1),
                label: "Bookings",
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.notifications, 2),
                label: "Notification",
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.person, 3),
                label: "Profile",
              ),
            ],
            selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _showUserProfile(BuildContext context) async {
    await showPopupCard<String>(
      context: context,
      builder: (context) {
        return PopupCard(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blue[200]!, width: 1),
          ),
          color: Colors.white,
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseAuth.instance.currentUser != null
                      ? _firestore
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue[100],
                        child: CircleAvatar(
                          radius: 56,
                          child: Icon(Icons.person, color: Colors.blue[800], size: 40),
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue[100],
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                        ),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final imageUrl = data?['profile_image'];
                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue[100],
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseAuth.instance.currentUser != null
                      ? _firestore
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        'Loading...',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.blue[900],
                        ),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return Text(
                        'User',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.blue[900],
                        ),
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    return Text(
                      data?['name'] ?? 'User',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.blue[900],
                      ),
                    );
                  },
                ),
                SizedBox(height: 8),
                Text(
                  userEmail ?? "Email not available",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: userEmail != null ? Colors.grey[700] : Colors.redAccent,
                  ),
                ),
                SizedBox(height: 16),
                Divider(color: Colors.blue[200]),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Log Out",
                                  style: GoogleFonts.poppins()),
                              content: Text("Are you sure you want to log out?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child:
                                  Text("Cancel", style: GoogleFonts.poppins()),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => ChoosePage()),
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Text("Log Out",
                                      style:
                                      GoogleFonts.poppins(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('Log Out',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                            color: Colors.blue[700], fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      offset: const Offset(-16, 80),
      alignment: Alignment.topRight,
      useSafeArea: true,
      dimBackground: true,
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return AnimatedScale(
      scale: _selectedIndex == index ? 1.3 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Icon(icon, size: 28),
    );
  }
}
class ExitConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 60),
            SizedBox(height: 16),
            Text(
              "Exit App?",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Are you sure you want to exit the app?",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
                textStyle: TextStyle(fontStyle: FontStyle.italic),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 4,
                  ),
                  child: Text(
                    'No',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 4,
                  ),
                  child: Text(
                    'Exit',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}