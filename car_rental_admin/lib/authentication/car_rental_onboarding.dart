import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'get_started_page.dart';
class CarRentalOnBoarding extends StatefulWidget {
  const CarRentalOnBoarding({super.key});

  @override
  State<CarRentalOnBoarding> createState() => _CarRentalOnBoardingState();
}

class _CarRentalOnBoardingState extends State<CarRentalOnBoarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image with 30% opacity and 20% black overlay
          Positioned.fill(
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.3, // Increased to 30% as requested
                  child: Image.asset(
                    'assets/images/car.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.2), // 20% black overlay
                ),
              ],
            ),
          ),
          // Foreground content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const GetStartedPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.yellow.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildOnboardingPage(
                        title: 'Alfa Romeo Stelvio',
                        description: 'Experience luxury and performance in one sophisticated package.',
                        location: 'The Woodlands, TX',
                        price: '\$60 /Per Day',
                        rating: '5.0',
                        carClass: '2024 Comfort Class',
                      ),
                      _buildOnboardingPage(
                        title: 'BMW X5',
                        description: 'A perfect blend of style, power, and advanced technology for your journey.',
                        location: 'Houston, TX',
                        price: '\$75 /Per Day',
                        rating: '4.8',
                        carClass: '2023 Luxury Class',
                      ),
                      _buildOnboardingPage(
                        title: 'Mercedes GLC',
                        description: 'Drive with elegance and state-of-the-art technology at its finest.',
                        location: 'Austin, TX',
                        price: '\$80 /Per Day',
                        rating: '4.9',
                        carClass: '2024 Premium Class',
                      ),
                    ],
                  ),
                ),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _currentPage > 0
                            ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                            : null,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                        child: Text(
                          'Prev',
                          style: GoogleFonts.poppins(
                            color: _currentPage > 0 ? Colors.black : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            height: 12,
                            width: _currentPage == index ? 24 : 12,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? Colors.yellow : Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        }),
                      ),
                      TextButton(
                        onPressed: _currentPage < 2
                            ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                            : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const GetStartedPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          _currentPage < 2 ? 'Next' : 'Finish',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required String location,
    required String price,
    required String rating,
    required String carClass,
  }) {
    return Card(
      color: Colors.grey[900],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_upward, color: Colors.yellow, size: 28),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    price,
                    style: GoogleFonts.poppins(
                      color: Colors.yellow,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      rating,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              carClass,
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}