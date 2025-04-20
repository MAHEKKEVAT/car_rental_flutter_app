import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; 

class PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.07, // Increased from 0.06
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: _buildSectionCard(context, '', [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 30, color: Colors.blue[600]),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Text(
                        'Your Privacy Matters',
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.of(context).size.width * 0.08, // Increased from 0.07
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // Removed MediaQuery, set fixed height
                  _buildParagraph(context,
                    'Understanding how we protect your information is important.',
                  ),
                ], isHeader: true),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              FadeInUp(
                duration: Duration(milliseconds: 700),
                child: Text(
                  'Effective Date: January 1, 2025', // Updated from 2023 to 2025
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.width * 0.045, // Increased from 0.04
                    color: Colors.grey[700],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              FadeInUp(
                duration: Duration(milliseconds: 800),
                child: _buildSectionCard(context, '1. Information We Collect', [
                  _buildParagraph(context,
                    'We collect information from you when you register on our app, place an order, subscribe to our newsletter, or interact with us in other ways. The types of information we may collect include your name, email address, phone number, and payment information.',
                  ),
                ]),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              FadeInUp(
                duration: Duration(milliseconds: 900),
                child: _buildSectionCard(context, '2. How We Use Your Information', [
                  _buildParagraph(context,
                    'We use the information we collect to provide, maintain, and improve our services, process transactions, communicate with you, and send you updates and promotional materials.',
                  ),
                ]),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: _buildSectionCard(context, '3. Data Security', [
                  _buildParagraph(context,
                    'We implement a variety of security measures to maintain the safety of your personal information. However, no method of transmission over the internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security.',
                  ),
                ]),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              FadeInUp(
                duration: Duration(milliseconds: 1100),
                child: _buildSectionCard(context, '4. Your Rights', [
                  _buildParagraph(context,
                    'You have the right to access, correct, or delete your personal information. You can also object to the processing of your data in certain circumstances. To exercise these rights, please contact us using the information provided below.',
                  ),
                ]),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              FadeInUp(
                duration: Duration(milliseconds: 1200),
                child: _buildSectionCard(context, '5. Changes to This Privacy Policy', [
                  _buildParagraph(context,
                    'We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new Privacy Policy on this page and updating the effective date. We encourage you to review this policy periodically for any updates.',
                  ),
                ]),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              FadeInUp(
                duration: Duration(milliseconds: 1300),
                child: _buildSectionCard(context, '6. Contact Us', [
                  _buildParagraph(context,
                    'If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at support@example.com.',
                  ),
                ]),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              FadeInUp(
                duration: Duration(milliseconds: 1400),
                child: Center(
                  child: Text(
                    'Thank you for trusting us with your information.',
                    style: GoogleFonts.poppins(
                      fontSize: MediaQuery.of(context).size.width * 0.04, // Increased from 0.035
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children, {bool isHeader = false}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: isHeader ? [Colors.blue[100]!, Colors.blue[50]!] : [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isHeader ? MediaQuery.of(context).size.width * 0.08 : MediaQuery.of(context).size.width * 0.055, // Increased from 0.05
                fontWeight: FontWeight.w700,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.045, // Increased from 0.04
          color: Colors.grey[800],
          height: 1.6,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}