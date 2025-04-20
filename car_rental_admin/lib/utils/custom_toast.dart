import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomToast {
  static void show(
      BuildContext context, {
        required String message,
        int durationSeconds = 3,
      }) {
    // Create an OverlayEntry for the toast
    OverlayEntry? overlayEntry;
    bool isVisible = false;

    // Animation controller
    final animationController = AnimationController(
      vsync: Overlay.of(context),
      duration: const Duration(milliseconds: 300),
    );

    // Slide animation from left to right
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0), // Start off-screen left
      end: const Offset(0, 0), // End at original position
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ));

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: ClipPath(
                  clipper: ToastClipper(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.yellow[600]!, // Lighter yellow
                          Colors.yellow[700]!, // Base yellow
                          Colors.yellow[800]!, // Darker yellow
                        ],
                      ),
                      border: Border.all(
                        color: Colors.yellow[600]!,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Car icon on the left
                        const Icon(
                          Icons.directions_car,
                          color: Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        // Message text
                        Expanded(
                          child: Text(
                            message,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Insert the overlay and start animation
    Overlay.of(context).insert(overlayEntry);
    animationController.forward();
    isVisible = true;

    // Remove the overlay after duration
    Future.delayed(Duration(seconds: durationSeconds), () async {
      if (isVisible) {
        // Slide out to the right
        await animationController.reverse();
        overlayEntry?.remove();
        overlayEntry = null;
        animationController.dispose();
      }
    });
  }
}

// Custom clipper for an attractive toast shape
class ToastClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final cornerRadius = 12.0;
    final tilt = 4.0; // Slight tilt effect

    path.moveTo(cornerRadius, 0);
    path.lineTo(size.width - cornerRadius - tilt, 0);
    path.quadraticBezierTo(
      size.width - tilt,
      0,
      size.width - tilt,
      cornerRadius,
    );
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );
    path.lineTo(cornerRadius + tilt, size.height);
    path.quadraticBezierTo(
      tilt,
      size.height,
      tilt,
      size.height - cornerRadius,
    );
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}