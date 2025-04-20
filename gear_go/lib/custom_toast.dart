import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomToast {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.CENTER,
    Color textColor = Colors.white,
    List<Color> gradientColors = const [Colors.blue, Colors.purple],
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Calculate position based on gravity
    double? top, bottom, left, right;
    switch (gravity) {
      case ToastGravity.TOP:
        top = 50.0;
        bottom = null;
        left = 0.0;
        right = 0.0;
        break;
      case ToastGravity.CENTER:
        top = null;
        bottom = null;
        left = 0.0;
        right = 0.0;
        break;
      case ToastGravity.BOTTOM:
        top = null;
        bottom = 50.0;
        left = 0.0;
        right = 0.0;
        break;
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay entry
    overlay.insert(overlayEntry);

    // Remove the overlay entry after the specified duration
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}

// Enum for toast gravity (similar to Fluttertoast)
enum ToastGravity {
  TOP,
  CENTER,
  BOTTOM,
}