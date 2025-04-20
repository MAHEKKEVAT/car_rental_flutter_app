import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'forgot_password.dart';
import 'sign_up_page.dart';
import '../home_page.dart';
import '../utils/custom_toast.dart';
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _carAdminIdController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _carAdminIdError;
  bool _isFirebaseConnected = false;

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      await Firebase.app();
      setState(() => _isFirebaseConnected = true);
    } catch (e) {
      setState(() => _isFirebaseConnected = false);
      print("Firebase connection check failed: $e");
    }
  }

  void _validateInputs() {
    setState(() {
      _emailError = _emailController.text.isEmpty
          ? 'Please Enter Email'
          : !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(_emailController.text)
          ? 'Please enter a valid email address'
          : null;
      _passwordError = _passwordController.text.isEmpty
          ? 'Please enter Password'
          : _passwordController.text.length < 6
          ? 'Password must be at least 6 characters'
          : null;
      _carAdminIdError = _carAdminIdController.text.isEmpty
          ? 'Please enter CarAdminID'
          : _carAdminIdController.text != 'CARADMIN2025'
          ? 'Invalid CarAdminID'
          : null;
    });
  }

  Future<void> _signIn() async {
    _validateInputs();
    if (_emailError == null && _passwordError == null && _carAdminIdError == null) {
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final userId = userCredential.user?.uid;
        if (userId != null) {
          final doc = await FirebaseFirestore.instance.collection('CarAdmin').doc(userId).get();
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>?;
            final storedAdminId = data?['adminId']?.toString();
            final storedEmail = data?['email']?.toString();
            print("Entered Email: ${_emailController.text}, Stored Email: $storedEmail, Entered CarAdminID: ${_carAdminIdController.text}, Stored AdminId: $storedAdminId");
            if (_emailController.text == storedEmail && _carAdminIdController.text == storedAdminId) {
              CustomToast.show(context, message: 'Sign In Successful!');
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
            } else {
              CustomToast.show(context, message: 'Email or CarAdminID does not match!');
              await FirebaseAuth.instance.signOut();
            }
          } else {
            CustomToast.show(context, message: 'User data not found in Firestore!');
            await FirebaseAuth.instance.signOut();
          }
        }
      } on FirebaseAuthException catch (e) {
        CustomToast.show(context, message: 'Error: ${e.message}');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _carAdminIdController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Leave Sign In?',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to leave? You’ll need to sign in again to access your account.',
          style: GoogleFonts.poppins(
            color: Colors.grey[300],
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel: Stay on page
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.yellow[700],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // OK: Allow back navigation
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: Colors.yellow[700],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
        Positioned.fill(
        child: Opacity(
        opacity: 0.25,
          child: Image.asset(
            'assets/images/car.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
          ),
        ),
      ),
      SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isFirebaseConnected)
                      GestureDetector(
                        onTap: () => CustomToast.show(context, message: 'Firebase connection working'),
                        child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Access your Car Rental Admin account',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[300],
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter Email';
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(value))
                      return 'Please enter a valid email address';
                    return null;
                  },
                ),
                if (_emailError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(_emailError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  errorText: _passwordError,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter Password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(_passwordError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _carAdminIdController,
                  label: 'CarAdminID',
                  hint: 'Enter your CarAdminID (e.g., admin@123)',
                  errorText: _carAdminIdError,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter CarAdminID';
                    return null;
                  },
                ),
                if (_carAdminIdError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(_carAdminIdError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        color: Colors.yellow[700],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 280,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          color: Colors.yellow[700],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ]
    ),

    ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 18),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[850],
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.yellow, width: 2),
            ),
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
        ),
      ],
    );
  }
}