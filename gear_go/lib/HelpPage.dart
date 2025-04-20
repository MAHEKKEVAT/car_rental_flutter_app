import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
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
                  'Help & Support',
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section
                      FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              BounceInDown(
                                child: Hero(
                                  tag: 'support-icon',
                                  child: Icon(
                                    Icons.support_agent,
                                    size: 60,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Need Assistance?',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Explore FAQs or contact us directly.',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // FAQs
                      FadeInUp(
                        delay: Duration(milliseconds: 200),
                        child: Text(
                          'Frequently Asked Questions',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      FadeInUp(
                        delay: Duration(milliseconds: 400),
                        child: _buildHelpItem(
                          question: 'How do I reset my password?',
                          answer:
                          'Go to the login page and tap "Forgot Password?". Follow the instructions sent to your email to reset it.',
                        ),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 600),
                        child: _buildHelpItem(
                          question: 'How do I contact support?',
                          answer:
                          'Reach us via email at support@luxeride.com, call us, or use the live chat feature in the app.',
                        ),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 800),
                        child: _buildHelpItem(
                          question: 'What payment methods are accepted?',
                          answer:
                          'We support major credit cards, PayPal, and bank transfers for secure payments.',
                        ),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 1000),
                        child: _buildHelpItem(
                          question: 'How do I update my profile?',
                          answer:
                          'Navigate to Settings > Account to edit your profile details, including name and contact info.',
                        ),
                      ),
                      FadeInUp(
                        delay: Duration(milliseconds: 1200),
                        child: _buildHelpItem(
                          question: 'Where are the terms and conditions?',
                          answer:
                          'Find them in the Settings menu or at the bottom of our app under "Legal".',
                        ),
                      ),
                      SizedBox(height: 30),
                      // Contact Us Section
                      FadeInUp(
                        delay: Duration(milliseconds: 1400),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
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
                                'Still Have Questions?',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Our team is here to help you 24/7.',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final Uri emailUri =
                                      Uri(scheme: 'mailto', path: 'support@luxeride.com');
                                      if (await canLaunchUrl(emailUri)) {
                                        await launchUrl(emailUri);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Unable to open email client')),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.email, color: Colors.white),
                                    label: Text(
                                      'Email Us',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600],
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final Uri phoneUri = Uri(scheme: 'tel', path: '+11234567890');
                                      if (await canLaunchUrl(phoneUri)) {
                                        await launchUrl(phoneUri);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Unable to open dialer')),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.phone, color: Colors.white),
                                    label: Text(
                                      'Call Us',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600],
                                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Live chat coming soon!')),
                                    );
                                  },
                                  icon: Icon(Icons.chat, color: Colors.white),
                                  label: Text(
                                    'Live Chat',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      // Footer
                      FadeInUp(
                        delay: Duration(milliseconds: 1600),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Thank you for visiting LuxeRide’s Help Center!',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialIcon(
                                    Icons.facebook,
                                    Colors.blue[600]!,
                                        () => _launchUrl('https://facebook.com/luxeride'),
                                  ),
                                  SizedBox(width: 16),
                                  _buildSocialIcon(
                                    Icons.camera_alt,
                                    Colors.pink[400]!,
                                        () => _launchUrl('https://instagram.com/luxeride'),
                                  ),
                                  SizedBox(width: 16),
                                  _buildSocialIcon(
                                    Icons.alternate_email,
                                    Colors.blue[400]!,
                                        () => _launchUrl('https://twitter.com/luxeride'),
                                  ),
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

  Widget _buildHelpItem({required String question, required String answer}) {
    return AnimatedScale(
      scale: 1.0,
      duration: Duration(milliseconds: 200),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.blue[800],
            ),
          ),
          iconColor: Colors.blue[600],
          collapsedIconColor: Colors.blue[400],
          childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error (optional)
    }
  }
}