import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'user_details_page.dart';
import 'utils/custom_toast.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image with 30% opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Customers',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.yellow[700]!.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Subtitle
                  Text(
                    'List of registered users',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[300],
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Users List from Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.yellow[700],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 4.0,
                              ),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        CustomToast.show(context, message: 'Error: ${snapshot.error}');
                        return Center(
                          child: Text(
                            'Error loading users',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No users found',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[300],
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      final users = snapshot.data!.docs;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.yellow[700]!.withOpacity(0.3),
                          thickness: 1,
                          height: 10,
                        ),
                        itemBuilder: (context, index) {
                          final userData = users[index].data() as Map<String, dynamic>;
                          final name = userData['name'] ?? 'Unknown';
                          final email = userData['email'] ?? 'No email';
                          final profileImage = userData['profile_image'];

                          return UserListItem(
                            userData: userData,
                            name: name,
                            email: email,
                            profileImage: profileImage,
                            index: index,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserListItem extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String name;
  final String email;
  final String? profileImage;
  final int index;

  const UserListItem({
    super.key,
    required this.userData,
    required this.name,
    required this.email,
    this.profileImage,
    required this.index,
  });

  @override
  _UserListItemState createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(userData: widget.userData),
          ),
        );
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.yellow[700]!.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.yellow[700]!, width: 1),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.yellow[700],
                child: Text(
                  '${widget.index + 1}',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              widget.profileImage != null
                  ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.yellow[700]!, width: 2),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.profileImage!,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 25,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => const CircleProgressIndicator(
                    color: Colors.yellow,
                    strokeWidth: 3.0,
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[700],
                    child: Text(
                      widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
                  : CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[700],
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.email,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom CircularProgressIndicator for image loading
class CircleProgressIndicator extends StatelessWidget {
  final Color color;
  final double strokeWidth;

  const CircleProgressIndicator({
    super.key,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}