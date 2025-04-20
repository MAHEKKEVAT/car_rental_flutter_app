import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecenetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recenets',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: 10, // Set your desired item count
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(),
              Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  // Circular image
                  leading: ClipOval(
                    child: Image.asset(
                      'assets/images/car1.jpg',
                      // Make sure to replace this with your correct image path
                      fit: BoxFit.cover,
                      width: 60, // Set the width of the circular image
                      height: 60, // Set the height of the circular image
                    ),
                  ),
                  title: Text(
                    'Recenets Car',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  subtitle: Text(
                    'This is the description for the recents car.',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      // Handle remove from favourites
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
