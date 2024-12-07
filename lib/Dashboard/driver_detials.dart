import 'package:didiportal/Helpers/Globle_variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/driver_model.dart';

class DriverScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drivers'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var drivers = snapshot.data!.docs
              .map((doc) => Driver.fromFirestore(doc))
              .toList();

          return ResponsiveGrid(drivers: drivers);
        },
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Driver> drivers;

  ResponsiveGrid({required this.drivers});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int gridCount = 1;
        if (constraints.maxWidth > 1200) {
          gridCount = 3;
        } else if (constraints.maxWidth > 830) {
          gridCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            return DriverCard(driver: drivers[index]);
          },
        );
      },
    );
  }
}

class DriverCard extends StatelessWidget {
  final Driver driver;

  DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 100,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          constraints: BoxConstraints(
            minHeight: 200, // Set a fixed height for the card
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.lightBlueAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(driver.profilePic),
                            radius: 40,
                            onBackgroundImageError: (_, __) {
                              AssetImage('assets/fallback_profile.png');
                            },
                            child: ClipOval(
                              child: Image.network(
                                driver.profilePic,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                      'assets/fallback_profile.png',
                                      fit: BoxFit.cover);
                                },
                              ),
                            ),
                          ),
                        ),
                       const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.name,
                              style:const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              driver.phoneNumber,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Ride Details') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DriverTripsScreen(driverId: driver.id),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Edit', 'Delete', 'Ride Details'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                      icon: Icon(Icons.more_vert),
                    ),
                  ],
                ),
               const SizedBox(height: 15),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                ),
                SizedBox(height: 10),
                Text(
                  'CNIC: ${driver.CNIC}',
                  style:const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Car: ${driver.carYear} ${driver.carColor} ${driver.make} ${driver.model}',
                  style:const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Number Plate: ${driver.numberPlate}',
                  style:const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Seats: ${driver.seats}',
                  style:const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DriverTripsScreen extends StatelessWidget {
  final String driverId;

  DriverTripsScreen({required this.driverId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('driverTrips').child(driverId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Trips'),
      ),
      body: FirebaseAnimatedList(
        query: ref,
        itemBuilder: (context, snapshot, animation, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.grey[100],
              child: ListTile(
                title: Row(
                  children: [
                    Text(
                        "Date: ${snapshot.child("tripDate").value.toString()}"),
                    Text(
                        "  Cost: ${snapshot.child("tripCost").value.toString()}"),
                    Text(
                        "  Fare: ${snapshot.child("tripFear").value.toString()}"),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text("From: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(snapshot
                        .child("location/tripPickLocation")
                        .value
                        .toString()),
                    Text("  To: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(snapshot
                        .child("location/tripDropLocation")
                        .value
                        .toString()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
