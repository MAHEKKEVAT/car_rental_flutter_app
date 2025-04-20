import 'package:flutter/material.dart';
import 'firebase_config.dart';
import 'ChoosePage.dart';
import 'HomePage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignInPage.dart';
import 'SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initializeFirebase(); // Initialize Firebase early
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Rental App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/ChoosePage': (context) => ChoosePage(),
        '/HomePage': (context) => HomePage(),
        '/SignInPage': (context) => SignInPage(),
        '/SignUpPage': (context) => SignUpPage(),
        '/SplashScreen': (context) => SplashScreen(),
      },
      home: InitialScreen(),
    );
  }
}

// Initial Screen to determine navigation
class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool? isFirstLaunch = prefs.getBool('firstLaunch');

      // Delay to show initial screen briefly
      await Future.delayed(Duration(seconds: 1));

      if (isFirstLaunch == null || isFirstLaunch) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthWrapper()),
        );
      }
    } catch (e) {
      // Fallback in case of any error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                painter: CarSilhouettePainter(),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 12,
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://img.icons8.com/ios-filled/50/000000/car.png',
                        width: 60,
                        height: 60,
                        color: Colors.blue[700],
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Car Rental',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.blue[700],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Find Your Perfect Ride',
      'description': 'Browse a wide selection of cars for any occasion.',
      'image': 'https://img.icons8.com/ios/100/000000/car-rental.png',
    },
    {
      'title': 'Book Easily',
      'description': 'Reserve your car with just a few taps.',
      'image': 'https://img.icons8.com/ios/100/000000/booking.png',
    },
    {
      'title': 'Drive Anywhere',
      'description': 'Enjoy flexible rentals and hit the road!',
      'image': 'https://img.icons8.com/ios/100/000000/road.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[50]!, Colors.teal[100]!],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(painter: CarSilhouettePainter()),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (int page) {
                        setState(() => _currentPage = page);
                      },
                      itemBuilder: (context, index) {
                        return OnboardingSlide(
                          title: _slides[index]['title']!,
                          description: _slides[index]['description']!,
                          imageUrl: _slides[index]['image']!,
                        );
                      },
                    ),
                  ),
                  _buildPageIndicator(),
                  _buildNavigationButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _slides.length,
              (index) => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 6),
            width: _currentPage == index ? 25 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: _currentPage == index ? Colors.teal[700] : Colors.teal[200],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: TextButton(
              onPressed: _currentPage > 0
                  ? () => _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              )
                  : null,
              child: Text(
                'Previous',
                style: TextStyle(
                  color: Colors.teal[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_currentPage < _slides.length - 1) {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('firstLaunch', false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthWrapper()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
            child: Text(
              _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Onboarding Slide Widget
class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: imageUrl,
            child: Image.network(
              imageUrl,
              height: 220,
              width: 220,
              color: Colors.teal[700],
            ),
          ),
          SizedBox(height: 40),
          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800],
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.teal[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Car Silhouette Painter
class CarSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.65, size.width * 0.9, size.height * 0.6);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width * 0.65, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.lineTo(size.width * 0.15, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.65, size.width * 0.2, size.height * 0.7);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.7), size.width * 0.05, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), size.width * 0.05, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Authentication Wrapper
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(); // Show splash while checking auth
        }
        if (snapshot.hasData) {
          // Show splash then go to HomePage
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/HomePage');
          });
          return SplashScreen();
        }
        return ChoosePage();
      },
    );
  }
}