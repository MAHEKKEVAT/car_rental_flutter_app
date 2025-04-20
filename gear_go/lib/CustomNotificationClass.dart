import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart'; // Added for sound

// Placeholder for the Page widget (replace with your actual Page class)
class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navigated Page')),
      body: Center(child: Text('This is the navigated page!')),
    );
  }
}

// Example page to trigger the notification
class AnotherPage extends StatefulWidget {
  @override
  _AnotherPageState createState() => _AnotherPageState();
}

class _AnotherPageState extends State<AnotherPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkTextAndShowNotification() {
    String text = _controller.text.toLowerCase();
    if (text.contains('ion')) {
      CustomNotificationClass.MahekCustomNotification(
        context,
        "This is a Title",
        "This is a Description",
        Page(), // Replace with your actual page widget
        logoIcon: Icons.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Another Page')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Type something (e.g., "ion")',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _checkTextAndShowNotification(),
            ),
            SizedBox(height: 20),
            Text(
              'Type "ion" to trigger a notification!',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNotificationClass {
  static void MahekCustomNotification(
      BuildContext context,
      String title,
      String description,
      Widget navigateToPage, {
        Duration displayDuration = const Duration(seconds: 4),
        IconData? logoIcon,
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CustomNotificationWidget(
        title: title,
        description: description,
        navigateToPage: navigateToPage,
        logoIcon: logoIcon ?? Icons.notifications,
        onClose: () => overlayEntry.remove(),
      ),
    );

    // Insert overlay
    overlay.insert(overlayEntry);

    // Play sound when notification appears
    final player = AudioPlayer();
    player.play(AssetSource('music/truecaller.mp3'));

    // Auto-dismiss after displayDuration
    Future.delayed(displayDuration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
      player.dispose(); // Clean up audio player
    });
  }
}

class _CustomNotificationWidget extends StatefulWidget {
  final String title;
  final String description;
  final Widget navigateToPage;
  final IconData logoIcon;
  final VoidCallback onClose;

  const _CustomNotificationWidget({
    required this.title,
    required this.description,
    required this.navigateToPage,
    required this.logoIcon,
    required this.onClose,
  });

  @override
  __CustomNotificationWidgetState createState() => __CustomNotificationWidgetState();
}

class __CustomNotificationWidgetState extends State<_CustomNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isTapped = true;
    });

    // Scale animation feedback
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _isTapped = false;
      });

      // Navigate to the specified page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => widget.navigateToPage),
      );

      // Close the notification
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedScale(
              scale: _isTapped ? 0.95 : 1.0,
              duration: Duration(milliseconds: 100),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800]!.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Logo
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[600]!.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.logoIcon,
                          color: Colors.blue[400],
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      // Title and Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.description,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      // Right Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/profile.png'),
                        backgroundColor: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}