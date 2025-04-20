import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'HomePage.dart';
import 'ForgotPasswordPage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _licenseNoController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _showAdditionalFields = false;
  bool _showVerifyEmailButton = false;
  bool _isVerifying = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _licenseNoController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _proceedToAdditionalFields() async {
    setState(() => _errorMessage = null);
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields.");
      return;
    }

    if (RegExp(r'\d').hasMatch(name)) {
      setState(() => _errorMessage = "Name cannot contain numbers.");
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = "Please enter a valid email address.");
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters long.");
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }

    setState(() => _showAdditionalFields = true);
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String mobileNumber = _mobileController.text.trim();
    String city = _cityController.text.trim();
    String pinCode = _pinCodeController.text.trim();
    String state = _stateController.text.trim();
    String country = _cityController.text.trim();
    String licenseNo = _licenseNoController.text.trim();

    if (mobileNumber.isEmpty ||
        city.isEmpty ||
        pinCode.isEmpty ||
        state.isEmpty ||
        country.isEmpty ||
        licenseNo.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all required fields.";
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobileNumber)) {
      setState(() {
        _errorMessage = "Please enter a valid mobile number (10 digits only).";
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(pinCode)) {
      setState(() {
        _errorMessage = "Please enter a valid pin code (6 digits).";
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'mobile_number': mobileNumber,
          'city': city,
          'pin_code': pinCode,
          'state': state,
          'country': country,
          'license_no': licenseNo,
          'dateCreated': DateTime.now(),
        });

        await user.sendEmailVerification();
        setState(() {
          _errorMessage = "Verification email sent! Check your inbox.";
          _showVerifyEmailButton = true;
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is not valid.";
          break;
        case 'weak-password':
          errorMessage = "The password is too weak.";
          break;
        default:
          errorMessage = "Registration failed: ${e.message}";
      }
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    User? user = _auth.currentUser;

    if (user != null) {
      await user.reload();
      user = _auth.currentUser;

      if (user!.emailVerified) {
        await _postUserNotificationCreated();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = "Email not verified. Check your inbox or spam.";
          _isVerifying = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "No user found. Please sign up again.";
        _isVerifying = false;
      });
    }
  }

  Future<void> _postUserNotificationCreated() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        String time = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
        await _firestore.collection('Users').doc(userId).collection('Notification').add({
          'title': "Account Created Successfully!",
          'description': "Welcome to our app! Your account has been created.",
          'time': time,
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error sending notification: $e");
    }
  }

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
              color: Colors.teal[700],
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
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      Positioned(
        top: 100,
        right: 20,
        child: Opacity(
          opacity: 0.15,
          child: CustomPaint(
            size: Size(150, 150),
            painter: TrianglePainter(color: Colors.green[700]!),
          ),
        ),
      ),
      // Main Content
      SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 40.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Text(
                        _showAdditionalFields ? "Complete Your Profile" : "Create Account",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _showAdditionalFields
                            ? "Fill in your details"
                            : "Sign up to get started",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),

                      // Form Fields
                      if (!_showAdditionalFields) ...[
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (RegExp(r'\d').hasMatch(value)) {
                              return 'Name cannot contain numbers';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty || !_isValidEmail(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: _toggleConfirmPasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _proceedToAdditionalFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildInputField(
                          controller: _mobileController,
                          label: 'Mobile Number',
                          icon: Icons.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                              return 'Please enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _pinCodeController,
                          label: 'Pin Code',
                          icon: Icons.pin_drop,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your pin code';
                            }
                            if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                              return 'Please enter a valid 6-digit pin code';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your city';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.map,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your state';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _countryController,
                          label: 'Country',
                          icon: Icons.public,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your country';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        _buildInputField(
                          controller: _licenseNoController,
                          label: 'License Number',
                          icon: Icons.credit_card,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your license number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (_showVerifyEmailButton) ...[
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isVerifying ? null : _verifyEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isVerifying
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Verify Email',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],

                      // Error Message
                      if (_errorMessage != null) ...[
                        SizedBox(height: 20),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            color: _errorMessage!.contains("sent")
                                ? Colors.green
                                : Colors.red,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: 20),

                      // Navigation Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                color: Colors.teal[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: Colors.teal[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ]
    ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal[700]),
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}