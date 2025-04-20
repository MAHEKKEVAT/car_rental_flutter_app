class CarDataModel {
  final int basicPrice;
  final String carBrand;
  final String carImage1;
  final String carImage2;
  final String carImage3;
  final String carImage4;
  final String carName;
  final String chassisNo;
  final String engineNo;
  final String features1;
  final String features2;
  final String features3;
  final String features4;
  final String features5;
  final String features6;
  final String fuelType;
  final int maxPrice;
  final int noOfSeats;
  final int plusPrice;
  final String randomID; // Keep randomID if you still need it
  final String documentId; // Document ID from Firestore

  CarDataModel({
    required this.basicPrice,
    required this.carBrand,
    required this.carImage1,
    required this.carImage2,
    required this.carImage3,
    required this.carImage4,
    required this.carName,
    required this.chassisNo,
    required this.engineNo,
    required this.features1,
    required this.features2,
    required this.features3,
    required this.features4,
    required this.features5,
    required this.features6,
    required this.fuelType,
    required this.maxPrice,
    required this.noOfSeats,
    required this.plusPrice,
    required this.randomID,
    required this.documentId, // Firestore document ID
  });

  // Updated factory constructor to accept documentId
  factory CarDataModel.fromJson(Map<String, dynamic> json, String docId) {
    return CarDataModel(
      basicPrice: json['basic_price'] as int,
      carBrand: json['car_brand'] as String,
      carImage1: json['car_image1'] as String,
      carImage2: json['car_image2'] as String,
      carImage3: json['car_image3'] as String,
      carImage4: json['car_image4'] as String,
      carName: json['car_name'] as String,
      chassisNo: json['chassis_no'] as String,
      engineNo: json['engine_no'] as String,
      features1: json['features1'] as String,
      features2: json['features2'] as String,
      features3: json['features3'] as String,
      features4: json['features4'] as String,
      features5: json['features5'] as String,
      features6: json['features6'] as String,
      fuelType: json['fuel_type'] as String,
      maxPrice: json['max_price'] as int,
      noOfSeats: json['no_of_seats'] as int,
      plusPrice: json['plus_price'] as int,
      randomID: json['randomID'] as String,
      documentId: docId, // Use the passed document ID
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basic_price': basicPrice,
      'car_brand': carBrand,
      'car_image1': carImage1,
      'car_image2': carImage2,
      'car_image3': carImage3,
      'car_image4': carImage4,
      'car_name': carName,
      'chassis_no': chassisNo,
      'engine_no': engineNo,
      'features1': features1,
      'features2': features2,
      'features3': features3,
      'features4': features4,
      'features5': features5,
      'features6': features6,
      'fuel_type': fuelType,
      'max_price': maxPrice,
      'no_of_seats': noOfSeats,
      'plus_price': plusPrice,
      'randomID': randomID,
    };
  }
}