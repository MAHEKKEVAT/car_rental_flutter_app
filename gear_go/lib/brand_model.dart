import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String imageUrl;
  final String name;
  final String type;
  final String id;

  BrandModel({
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.id,
  });

  factory BrandModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BrandModel(
      imageUrl: data['img_url'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown Brand',
      type: data['type'] as String? ?? 'unknown',
      id: doc.id,
    );
  }
}
