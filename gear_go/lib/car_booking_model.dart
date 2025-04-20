import 'package:cloud_firestore/cloud_firestore.dart';
class CarBooking {
  final String id;
  final String documentId;
  final String fromLocation;
  final String toLocation;
  final String fromAddress;
  final String toAddress;
  final Timestamp pickUpDateTime;
  final Timestamp returnDateTime;
  final String? subscription;
  final String? seats;
  final double distance;
  final double totalPrice;
  final Timestamp bookingTime;
  final String status;
  final String carImage1;
  final String carName;
  final String? carBrand;
  final String? paymentMethod;
  final String? userName;
  final String? userEmail;
  final String? userMobile;
  final String? userCity;
  final String? userState;
  final String? userCountry;
  final String? userPinCode;
  final String? userLicense;

  CarBooking({
    required this.id,
    required this.documentId,
    required this.fromLocation,
    required this.toLocation,
    required this.fromAddress,
    required this.toAddress,
    required this.pickUpDateTime,
    required this.returnDateTime,
    this.subscription,
    this.seats,
    required this.distance,
    required this.totalPrice,
    required this.bookingTime,
    required this.status,
    required this.carImage1,
    required this.carName,
    this.carBrand,
    this.paymentMethod,
    this.userName,
    this.userEmail,
    this.userMobile,
    this.userCity,
    this.userState,
    this.userCountry,
    this.userPinCode,
    this.userLicense,
  });

  factory CarBooking.fromFirestore(Map<String, dynamic> data, String id) {
    return CarBooking(
      id: id,
      documentId: data['documentId'] ?? '',
      fromLocation: data['fromLocation'] ?? '',
      toLocation: data['toLocation'] ?? '',
      fromAddress: data['fromAddress'] ?? '',
      toAddress: data['toAddress'] ?? '',
      pickUpDateTime: data['pickUpDateTime'] ?? Timestamp.now(),
      returnDateTime: data['returnDateTime'] ?? Timestamp.now(),
      subscription: data['subscription'],
      seats: data['seats'],
      distance: (data['distance'] ?? 0.0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      bookingTime: data['bookingTime'] ?? Timestamp.now(),
      status: data['status'] ?? 'Pending',
      carImage1: data['carImage1'] ?? '',
      carName: data['carName'] ?? '',
      carBrand: data['car_brand'],
      paymentMethod: data['payment_method'],
      userName: data['userName'],
      userEmail: data['userEmail'],
      userMobile: data['userMobile'],
      userCity: data['userCity'],
      userState: data['userState'],
      userCountry: data['userCountry'],
      userPinCode: data['userPinCode'],
      userLicense: data['userLicense'],
    );
  }
}