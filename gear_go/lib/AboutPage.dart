import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Background Shapes
          Positioned(
            top: -50,
            left: -50,
            child: Opacity(
              opacity: 0.2,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[600],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Main Content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.blue[600],
                elevation: 0,
                pinned: true,
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Text(
                  'About Us',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Logo
                      FadeInDown(
                        child: Center(
                          child: Hero(
                            tag: 'app-logo',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/car.png',
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      // Header
                      FadeInUp(
                        child: Text(
                          'Your Ultimate Car Rental Experience',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Our Story
                      FadeInUp(
                        delay: Duration(milliseconds: 200),
                        child: _buildSectionCard(
                          title: 'Our Story',
                          content:
                          'Welcome to LuxeRide! We launched with a vision to redefine luxury car rentals. Frustrated by outdated booking systems, we built a platform that’s seamless, stylish, and driver-centric.',
                        ),
                      ),
                      SizedBox(height: 20),
                      // What We Offer
                      FadeInUp(
                        delay: Duration(milliseconds: 400),
                        child: _buildSectionTitle('What We Offer'),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 600),
                        child: _buildFeaturesGrid(context),
                      ),
                      SizedBox(height: 20),
                      // Our Mission
                      FadeInUp(
                        delay: Duration(milliseconds: 800),
                        child: _buildSectionCard(
                          title: 'Our Mission',
                          content:
                          'At LuxeRide, we empower you to travel in unparalleled style and comfort. Our commitment is to deliver a transparent, reliable, and exceptional rental experience.',
                        ),
                      ),
                      SizedBox(height: 20),
                      // Connect With Us
                      FadeInUp(
                        delay: Duration(milliseconds: 1000),
                        child: _buildSectionCard(
                          title: 'Connect With Us',
                          contentWidget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'We’d love to hear from you! Reach out anytime:',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildContactRow(
                                Icons.email_outlined,
                                'support@luxeride.com',
                                    () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Email feature coming soon!')),
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              _buildContactRow(
                                Icons.phone_outlined,
                                '+1 (123) 456-7890',
                                    () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Phone feature coming soon!')),
                                  );
                                },
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Contact form coming soon!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Contact Us',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      // Footer
                      FadeInUp(
                        delay: Duration(milliseconds: 1200),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Thank you for choosing LuxeRide!',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[700],
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialIcon(Icons.facebook, Colors.blue[600]!),
                                  SizedBox(width: 16),
                                  _buildSocialIcon(Icons.camera_alt, Colors.pink[400]!),
                                  SizedBox(width: 16),
                                  _buildSocialIcon(Icons.alternate_email, Colors.blue[400]!),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue[600],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          contentWidget ??
              Text(
                content!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      {
        'icon': Icons.directions_car,
        'title': 'Luxury Fleet',
        'desc': 'Choose from premium sedans, SUVs, and sports cars.',
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Easy Booking',
        'desc': 'Book your car in seconds with our intuitive app.',
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Secure Payments',
        'desc': 'Safe transactions with trusted payment gateways.',
      },
      {
        'icon': Icons.headset_mic,
        'title': '24/7 Support',
        'desc': 'Our team is here to help anytime, anywhere.',
      },
      {
        'icon': Icons.design_services,
        'title': 'Sleek Interface',
        'desc': 'Navigate effortlessly with our user-friendly design.',
      },
      {
        'icon': Icons.star_border,
        'title': 'Exclusive Perks',
        'desc': 'Unlock special offers and loyalty rewards.',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _FeatureCard(
          icon: features[index]['icon'] as IconData,
          title: features[index]['title'] as String,
          description: features[index]['desc'] as String,
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.blue[700],
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Placeholder for social media links
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  __FeatureCardState createState() => __FeatureCardState();
}

class __FeatureCardState extends State<_FeatureCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isTapped ? 0.95 : 1.0,
      duration: Duration(milliseconds: 200),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isTapped = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isTapped = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isTapped = false;
          });
        },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.blue[600], size: 36),
              SizedBox(height: 8),
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                widget.description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}