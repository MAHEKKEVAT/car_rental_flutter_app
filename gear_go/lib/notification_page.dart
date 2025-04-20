import 'package:flutter/material.dart';
import 'package:gear_go/CustomNotificationClass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart'; // Added for sound

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        leading: Icon(Icons.notifications_active, color: Colors.white),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: userId == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: Colors.blue[300], size: 60),
            SizedBox(height: 16),
            Text(
              "Please log in to view notifications",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Notification')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.blue[600]!,
                size: 50,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    color: Colors.blue[300],
                    size: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No Notifications Yet",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You're all caught up!",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              String formattedTime;
              dynamic timeData = notification['time'];
              if (timeData is Timestamp) {
                formattedTime = DateFormat('MMM dd, yyyy - HH:mm').format(timeData.toDate());
              } else if (timeData is String) {
                formattedTime = timeData;
                try {
                  final parsedDate = DateTime.parse(timeData);
                  formattedTime = DateFormat('MMM dd, yyyy - HH:mm').format(parsedDate);
                } catch (e) {
                  // Keep original string if parsing fails
                }
              } else {
                formattedTime = 'Unknown Time';
              }
              // Check if status exists, default to false (unread) if not
              final bool isRead = notification.data() != null &&
                  (notification.data()! as Map<String, dynamic>).containsKey('status') &&
                  notification['status'] == 'read';

              return FadeInDown(
                delay: Duration(milliseconds: index * 100),
                child: Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    color: Colors.red[400],
                    padding: EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Text('Confirm Deletion', style: GoogleFonts.poppins()),
                        content: Text('Delete this notification permanently?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel', style: GoogleFonts.poppins()),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await FirebaseFirestore.instance
                        .collection('Users')
                        .doc(userId)
                        .collection('Notification')
                        .doc(notification.id)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Notification deleted"),
                        backgroundColor: Colors.blue[600],
                      ),
                    );
                  },
                  child: NotificationItem(
                    title: notification['title'] ?? 'No Title',
                    description: notification['description'] ?? 'No Description',
                    dateTime: formattedTime,
                    docId: notification.id,
                    isRead: isRead,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatefulWidget {
  final String title;
  final String description;
  final String dateTime;
  final String docId;
  final bool isRead;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.docId,
    required this.isRead,
  }) : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool _isExpanded = false;

  IconData _getLeadingIcon() {
    if (widget.title.toLowerCase().contains('success')) {
      return Icons.check_circle;
    } else if (widget.title.toLowerCase().contains('error') || widget.title.toLowerCase().contains('fail')) {
      return Icons.warning;
    }
    return Icons.notifications;
  }

  Color _getIconColor() {
    if (widget.title.toLowerCase().contains('success')) {
      return Colors.green[600]!;
    } else if (widget.title.toLowerCase().contains('error') || widget.title.toLowerCase().contains('fail')) {
      return Colors.red[600]!;
    }
    return Colors.blue[600]!;
  }

  Future<void> _markAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Notification')
          .doc(widget.docId)
          .set({'status': 'read'}, SetOptions(merge: true)); // Merge to add status dynamically
      CustomNotificationClass.MahekCustomNotification(
        context,
        "Notification Marked",
        "This notification has been marked as read.",
        Page(),
        logoIcon: Icons.check,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          Future.delayed(Duration(milliseconds: 300), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailPage(
                  title: widget.title,
                  description: widget.description,
                  dateTime: widget.dateTime,
                ),
              ),
            );
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(5, 5),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(-5, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getIconColor().withOpacity(0.1),
                  child: Icon(_getLeadingIcon(), color: _getIconColor()),
                ),
                title: Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: widget.isRead ? FontWeight.normal : FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  widget.dateTime,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.isRead)
                      IconButton(
                        icon: Icon(Icons.mark_chat_read, color: Colors.blue[700]),
                        onPressed: _markAsRead,
                      ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.blue[700],
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isExpanded ? 60 : 0,
                child: _isExpanded
                    ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    widget.description,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String dateTime;

  const NotificationDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.dateTime,
  }) : super(key: key);

  String _getNotificationType() {
    if (title.toLowerCase().contains('success')) {
      return 'Success';
    } else if (title.toLowerCase().contains('error') || title.toLowerCase().contains('fail')) {
      return 'Error';
    }
    return 'Info';
  }

  Color _getTypeColor() {
    if (title.toLowerCase().contains('success')) {
      return Colors.green[600]!;
    } else if (title.toLowerCase().contains('error') || title.toLowerCase().contains('fail')) {
      return Colors.red[600]!;
    }
    return Colors.blue[600]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text(
          'Notification Details',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'notification-$title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getNotificationType(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(),
                  ),
                ),
              ),
              Divider(
                color: Colors.blue[300],
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[400]!.withOpacity(0.9),
                      Colors.grey!.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
            alignment: Alignment.centerRight,
                child:   Text(
                  dateTime,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navigated Page')),
      body: Center(child: Text('This is the navigated page!')),
    );
  }
}

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
                labelText: 'Type something',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Just type something here!',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}