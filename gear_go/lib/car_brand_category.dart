import 'package:flutter/material.dart';
import 'package:gear_go/view_all_car_brand_category.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:animate_do/animate_do.dart'; // Added for animations
import 'view_car_brand_category.dart';
import 'brand_model.dart';

class CarBrandCategory extends StatelessWidget {
  const CarBrandCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeIn(
                  duration: Duration(milliseconds: 800),
                  child: Text(
                    'Popular Brands',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewALLCarBrandCategory(title: 'All Brands', brandType: "")),
                    );
                  },
                  child: FadeIn(
                    duration: Duration(milliseconds: 800),
                    child: Text(
                      'See All',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 110, // Decreased from 140
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('Brands').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error fetching brands',
                      style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 16),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.twistingDots(
                      leftDotColor: Colors.blue[700]!,
                      rightDotColor: Colors.blue[700]!,
                      size: 40, // Decreased from 50
                    ),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No brands found',
                      style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final brand = BrandModel.fromFirestore(snapshot.data!.docs[index]);

                    return BounceIn(
                      duration: Duration(milliseconds: 800 + (index * 200)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewCarBrandCategory(title: brand.name, brandType: brand.type, brand: brand),
                            ),
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            width: 100, // Decreased from 120
                            margin: EdgeInsets.only(left: index == 0 ? 15 : 8, right: index == snapshot.data!.docs.length - 1 ? 15 : 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60, // Decreased from 80
                                  height: 60, // Decreased from 80
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Colors.blue[200]!, Colors.blue[600]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue[100]!.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: brand.imageUrl.isNotEmpty
                                        ? Image.network(
                                      brand.imageUrl,
                                      fit: BoxFit.contain,
                                      color: Colors.white.withOpacity(0.8),
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return LoadingAnimationWidget.twistingDots(
                                          leftDotColor: Colors.blue[700]!,
                                          rightDotColor: Colors.blue[700]!,
                                          size: 25, // Decreased from 30
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                        size: 25, // Decreased from 30
                                      ),
                                    )
                                        : Icon(
                                      Icons.directions_car_outlined,
                                      size: 25, // Decreased from 35
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8), // Decreased from 12
                                Text(
                                  brand.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[900],
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}