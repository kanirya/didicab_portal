import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Driver {
  final String id;
  final String name;
  final String CNIC;
  final String phoneNumber;
  final String profilePic;
  final String make;
  final String model;
  final String numberPlate;
  final String carColor;
  final String carYear;
  final String createdAt;
  final String deviceToken;
  final String seats;

  Driver({
    required this.id,
    required this.name,
    required this.CNIC,
    required this.phoneNumber,
    required this.profilePic,
    required this.make,
    required this.model,
    required this.numberPlate,
    required this.carColor,
    required this.carYear,
    required this.createdAt,
    required this.deviceToken,
    required this.seats,
  });

  factory Driver.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Driver(
      id: doc.id,
      name: data['name'] ?? '',
      CNIC: data['CNIC'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePic: data['profilePic'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      carColor: data['carColor'] ?? '',
      carYear: data['carYear'] ?? '',
      createdAt: data['createdAt'] ?? '',
      deviceToken: data['deviceToken'] ?? '',
      seats:data['seats'] ?? '',
    );
  }
}

class Billing {
  String userId;
  double billingAmount;
  int totalTrips;

  Billing({
    required this.userId,
    required this.billingAmount,
    required this.totalTrips,
  });

  factory Billing.fromRealtimeDatabase(DataSnapshot snapshot) {
    Map data = snapshot.value as Map;
    return Billing(
      userId: snapshot.key ?? '',
      billingAmount: data['billingAmount'] ?? 0.0,
      totalTrips: data['totalTrips'] ?? 0,
    );
  }
}


Future<Map<String, dynamic>> fetchDriverData(String userId) async {
  // Fetch driver details from Firestore
  DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance.collection('drivers').doc(userId).get();
  Driver driver = Driver.fromFirestore(driverSnapshot);

  // Fetch billing data from Realtime Database
  DataSnapshot billingSnapshot = await FirebaseDatabase.instance.ref('DriverBilling/$userId').get();
  Billing billing = Billing.fromRealtimeDatabase(billingSnapshot);

  return {'driver': driver, 'billing': billing};
}

