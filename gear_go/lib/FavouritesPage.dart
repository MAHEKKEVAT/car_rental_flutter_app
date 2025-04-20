import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gear_go/car_data_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'view_car_page.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<CarDataModel> _favoriteCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteCars();
  }

  Future<void> _fetchFavoriteCars() async {
    setState(() {
      _isLoading = true;
    });
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final favoritesSnapshot = await _firestore
            .collection('Users')
            .doc(user.uid)
            .collection('Favourites')
            .get();

        if (favoritesSnapshot.docs.isNotEmpty) {
          List<String> favoriteCarDocumentIds = favoritesSnapshot.docs
              .map((doc) => doc['carDocumentId'] as String)
              .toList();

          if (favoriteCarDocumentIds.isNotEmpty) {
            final carsSnapshot = await _firestore
                .collection('CarData')
                .where(FieldPath.documentId, whereIn: favoriteCarDocumentIds)
                .get();

            _favoriteCars = carsSnapshot.docs.map((doc) {
              return CarDataModel.fromJson(
                  doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
          }
        }
      } catch (e) {
        print("Error fetching favorite cars: $e");
        // Handle error, maybe show a snackbar
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.blue[800]),
      ),
      body: _isLoading
          ? Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: Colors.blue[800]!,
          size: 60,
        ),
      )
          : _favoriteCars.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 90, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              'No favorite cars yet.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _favoriteCars.length,
        itemBuilder: (context, index) {
          final car = _favoriteCars[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCarPage(carData: car),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[200], // Placeholder background
                            child: Image.network(
                              car.carImage1,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue[800],
                                    value: loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.error_outline, color: Colors.red),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      car.carName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${car.basicPrice}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            _showRemoveConfirmationDialog(context, car.documentId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRemoveConfirmationDialog(
      BuildContext context, String carDocumentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Remove from Favorites?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to remove this car from your favorites?',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                _removeFromFavorites(carDocumentId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeFromFavorites(String carDocumentId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('Users')
            .doc(user.uid)
            .collection('Favourites')
            .where('carDocumentId', isEqualTo: carDocumentId)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
        _fetchFavoriteCars(); // Refresh the list after removal
        Fluttertoast.showToast(
          msg: "Removed from Favorites!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
      } catch (e) {
        print("Error removing from favorites: $e");
        Fluttertoast.showToast(
          msg: "Failed to remove from favorites. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }
}