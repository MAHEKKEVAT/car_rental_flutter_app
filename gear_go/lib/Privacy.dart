import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fade_in_animation/fade_in_animation.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';

class Policy extends StatefulWidget {
  @override
  _PolicyState createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue[200]!), // Changed to blue shade
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blue[600]),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.poppins(
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600], // Enhanced app bar color
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.check_circle_outline,
                '1. Acceptance of Terms',
                'By using this service, you agree to be bound by these terms and conditions.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.lock_outline,
                '2. Privacy Policy',
                'Your personal information will be handled in accordance with our privacy policy.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.person_outline,
                '3. User Responsibilities',
                'You are responsible for maintaining the confidentiality of your account and password.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.warning_amber_outlined,
                '4. Prohibited Activities',
                'You must not engage in any illegal or unauthorized activities while using this service.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.copyright_outlined,
                '5. Intellectual Property',
                'All content and materials on this platform are protected by intellectual property laws.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(child: _buildPolicyItem(
                Icons.error_outline,
                '6. Limitation of Liability',
                'We are not liable for any indirect, incidental, or consequential damages.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.cancel_outlined,
                '7. Termination',
                'We reserve the right to terminate your access to the service at any time.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.update_outlined,
                '8. Changes to Terms',
                'We may update these terms and conditions from time to time.',
              ),
            ),
            _buildDivider(),
            FadeInAnimation(
              child: _buildPolicyItem(
                Icons.email_outlined,
                '9. Contact Information',
                'For any questions, please contact us at support@example.com.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04), // Responsive padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card with rounded corners and blue border
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[300]!, width: 1), // Blue border
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03), // Responsive padding
            child: Icon(
              icon,
              color: Colors.blue[600],
              size: MediaQuery.of(context).size.width * 0.07, // Responsive icon size
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 1,
      color: Colors.blue[200], // Changed to blue shade
      indent: MediaQuery.of(context).size.width * 0.12, // Responsive indent
    );
  }
}