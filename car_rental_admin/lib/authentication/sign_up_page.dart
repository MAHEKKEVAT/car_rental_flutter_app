import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/custom_toast.dart';
import 'forgot_password.dart';
import 'sign_in_page.dart';
import 'set_location_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminIdController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _adminIdFocus = FocusNode();

  // Track whether each field has been focused
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _mobileTouched = false;
  bool _passwordTouched = false;
  bool _confirmPasswordTouched = false;
  bool _adminIdTouched = false;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        setState(() => _nameTouched = true);
      }
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        setState(() => _emailTouched = true);
      }
    });
    _mobileFocus.addListener(() {
      if (!_mobileFocus.hasFocus) {
        setState(() => _mobileTouched = true);
      }
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        setState(() => _passwordTouched = true);
      }
    });
    _confirmPasswordFocus.addListener(() {
      if (!_confirmPasswordFocus.hasFocus) {
        setState(() => _confirmPasswordTouched = true);
      }
    });
    _adminIdFocus.addListener(() {
      if (!_adminIdFocus.hasFocus) {
        setState(() => _adminIdTouched = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminIdController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _adminIdFocus.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        print('Attempting sign-up with email: ${_emailController.text}, password length: ${_passwordController.text.length}');
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final userId = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('CarAdmin').doc(userId).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _mobileController.text.trim(),
          'adminId': _adminIdController.text.trim(),
          'selectedLocation': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        Fluttertoast.showToast(msg: 'Sign Up Successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SetLocationPage(userId: userId)),
        );
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: 'Error: ${e.message ?? e.toString()}');
        print("FirebaseAuthException: $e");
      } catch (e) {
        Fluttertoast.showToast(msg: 'Unexpected error: $e');
        print("Unexpected error during sign-up: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      CustomToast.show(context, message: 'Fill correct data', durationSeconds: 5);

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback background
      body: Stack(
        children: [
          // Background image covering entire screen
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/images/car.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Form content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new Car Rental Admin account',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      keyboardType: TextInputType.text,
                      touched: _nameTouched,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter Full Name';
                        if (value.contains(RegExp(r'[0-9]'))) return 'Name must not contain numbers';
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value))
                          return 'Name must contain only alphabetic characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      touched: _emailTouched,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter Email';
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value))
                          return 'Please enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _mobileController,
                      focusNode: _mobileFocus,
                      label: 'Mobile Number',
                      hint: 'Enter your mobile number',
                      keyboardType: TextInputType.phone,
                      touched: _mobileTouched,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter Mobile Number';
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Mobile Number must be exactly 10 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      touched: _passwordTouched,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter Password';
                        if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$')
                            .hasMatch(value))
                          return 'Password must be 8+ chars with 1 uppercase, 1 lowercase, 1 special char';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      obscureText: _obscureConfirmPassword,
                      touched: _confirmPasswordTouched,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm Password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _adminIdController,
                      focusNode: _adminIdFocus,
                      label: 'Car Owner Admin ID',
                      hint: 'Enter ADMIN ID',
                      touched: _adminIdTouched,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter Admin ID';
                        if (value != 'CARADMIN2025') return 'Invalid Admin ID';
                        return null;
                      },
                    ),
                    const SizedBox(height: 5),
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
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 280,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInPage()),
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              color: Colors.yellow[700],
                              fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    required bool touched,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 16),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: suffixIcon,
          ),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
        ),
        if (validator != null && touched && !focusNode.hasFocus && validator(controller.text) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              validator(controller.text) ?? '',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }
}