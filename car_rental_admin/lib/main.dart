import 'package:car_rental_admin/home_page.dart';
import 'package:car_rental_admin/authentication/sign_in_page.dart';
import 'package:car_rental_admin/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'dart:async';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appwriteClient = appwrite.Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('67e8384a0024f79666ba');

  AppwriteSingleton.instance.client = appwriteClient;

  runApp(const MyApp());
}

class AppwriteSingleton {
  static final AppwriteSingleton instance = AppwriteSingleton._internal();
  appwrite.Client? client;

  factory AppwriteSingleton() => instance;
  AppwriteSingleton._internal();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _blinkController;
  late AnimationController _textController;
  late Animation<Color?> _textColorAnimation;
  bool _isIconVisible = true;
  bool _isInitialized = false;
  bool _isChecking = false;
  bool _hasInternet = false;

  @override
  void initState() {
    super.initState();
    print('SplashScreen: Initializing animations');
    _setupAnimations();
    _startAppFlow();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    _scaleController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _scaleController.forward();

    _blinkController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isIconVisible = false);
          _blinkController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() => _isIconVisible = true);
          _blinkController.forward();
        }
      });
    _blinkController.forward();

    _textController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _textColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.yellow[700],
    ).animate(_textController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _textController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _textController.forward();
        }
      });
    _textController.forward();
  }

  Future<void> _startAppFlow() async {
    print('SplashScreen: Starting app flow');
    await _checkInternetConnection();
    if (_hasInternet && mounted) {
      print('SplashScreen: Internet available, proceeding with initialization');
      await _initializeServices();
      if (_isInitialized) {
        print('SplashScreen: Initialization successful, starting navigation timer');
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            _navigate();
          }
        });
      } else {
        print('SplashScreen: Initialization failed, starting fallback navigation timer');
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            print('SplashScreen: Navigating to SignInPage as fallback');
            _blinkController.stop();
            _scaleController.stop();
            _textController.stop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          }
        });
      }
    } else if (mounted) {
      print('SplashScreen: No internet, showing no-internet dialog');
      _showNoInternetDialog();
    }
  }

  Future<void> _checkInternetConnection() async {
    if (_isChecking) {
      print('SplashScreen: Already checking connectivity, skipping');
      return;
    }

    setState(() {
      _isChecking = true;
    });
    print('SplashScreen: Starting internet check');

    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print('SplashScreen: Internet Check - ${hasInternet ? 'ON' : 'OFF'}');
      setState(() {
        _hasInternet = hasInternet;
      });
    } catch (e) {
      print('SplashScreen: Error checking connectivity - $e');
      setState(() {
        _hasInternet = false;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
      print('SplashScreen: Internet check completed');
    }
  }

  Future<void> _initializeServices() async {
    try {
      print('SplashScreen: Starting Firebase and Appwrite initialization');
      if (Firebase.apps.isNotEmpty) {
        print('SplashScreen: Firebase is initialized');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            CustomToast.show(context, message: 'Firebase Connected!');
          }
        });
      } else {
        print('SplashScreen: Firebase not initialized');
        throw Exception('Firebase initialization failed');
      }

      if (AppwriteSingleton.instance.client != null) {
        print('SplashScreen: Appwrite client initialized');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Appwrite Client Connected', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      } else {
        print('SplashScreen: Appwrite client not initialized');
        throw Exception('Appwrite client initialization failed');
      }

      setState(() {
        _isInitialized = true;
      });
      print('SplashScreen: Initialization completed successfully');
    } catch (e) {
      print('SplashScreen: Initialization Error - $e');
      setState(() {
        _isInitialized = false;
      });
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.grey[800],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.yellow,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Internet Connection',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your mobile data or Wi-Fi connection and try again.',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[300],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('SplashScreen: Exit App button pressed');
                          SystemNavigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Exit App',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('SplashScreen: Retry button pressed');
                          Navigator.of(context).pop();
                          setState(() {
                            _isChecking = true;
                          });
                          await _checkInternetConnection();
                          if (_hasInternet && mounted) {
                            print('SplashScreen: Internet restored, proceeding with initialization');
                            await _initializeServices();
                            if (_isInitialized) {
                              print('SplashScreen: Initialization successful, starting navigation timer');
                              Timer(const Duration(seconds: 3), () {
                                if (mounted) {
                                  _navigate();
                                }
                              });
                            } else {
                              print('SplashScreen: Initialization failed, navigating to SignInPage');
                              _blinkController.stop();
                              _scaleController.stop();
                              _textController.stop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignInPage()),
                              );
                            }
                          } else if (mounted) {
                            print('SplashScreen: Still no internet, showing dialog again');
                            _showNoInternetDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigate() {
    print('SplashScreen: Navigating to next page');
    _blinkController.stop();
    _scaleController.stop();
    _textController.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('SplashScreen: Auth state waiting, staying on SplashScreen');
              return const SplashScreen();
            } else if (snapshot.hasData) {
              print('SplashScreen: User logged in, navigating to HomePage');
              return const HomePage();
            } else {
              print('SplashScreen: No user, navigating to SignInPage');
              return const SignInPage();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('SplashScreen: Disposing animation controllers');
    _fadeController.dispose();
    _scaleController.dispose();
    _blinkController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D), Color(0xFF404040)],
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: _scaleAnimation, child: child),
                        child: _isIconVisible
                            ? CircleAvatar(
                          radius: 75 * _scaleAnimation.value,
                          backgroundColor: Colors.yellow[700],
                          child: const Icon(Icons.directions_car, size: 60, color: Colors.black),
                        )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Text(
                        'Car Rental Admin',
                        style: GoogleFonts.poppins(
                          color: _textColorAnimation.value,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.yellow[700]!.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
                      strokeWidth: 4,
                      backgroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isChecking)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            ),
        ],
      ),
    );
  }
}