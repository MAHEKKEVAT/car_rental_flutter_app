class CarBooking {
  final String id;
  final String documentId;
  final String fromLocation;
  final String toLocation;
  final String fromAddress;
  final String toAddress;
  final DateTime pickUpDateTime;
  final DateTime returnDateTime;
  final String? subscription;
  final String? seats;
  final double distance;
  final double totalPrice;
  final DateTime bookingTime;
  final String status;
  final String carImage1;
  final String carName;

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
  });

  factory CarBooking.fromFirestore(Map<String, dynamic> data, String id) {
    return CarBooking(
      id: id,
      documentId: data['documentId'] ?? '',
      fromLocation: data['fromLocation'] ?? '',
      toLocation: data['toLocation'] ?? '',
      fromAddress: data['fromAddress'] ?? '',
      toAddress: data['toAddress'] ?? '',
      pickUpDateTime: DateTime.parse(data['pickUpDateTime'] ?? DateTime.now().toIso8601String()),
      returnDateTime: DateTime.parse(data['returnDateTime'] ?? DateTime.now().toIso8601String()),
      subscription: data['subscription'],
      seats: data['seats'],
      distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      bookingTime: DateTime.parse(data['bookingTime'] ?? DateTime.now().toIso8601String()),
      status: data['status'] ?? 'Pending',
      carImage1: data['carImage1'] ?? 'https://via.placeholder.com/150',
      carName: data['carName'] ?? 'Unknown Car',
    );
  }
}