import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PassengerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passengers'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Define your menu actions here
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('passengers').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var passengers = snapshot.data!.docs.map((doc) => Passenger.fromFirestore(doc)).toList();

          return ResponsiveGrid(passengers: passengers);
        },
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Passenger> passengers;

  ResponsiveGrid({required this.passengers});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int gridCount = 1;
        if (constraints.maxWidth > 1200) {
          gridCount = 4;
        } else if (constraints.maxWidth > 800) {
          gridCount = 3;
        }else if (constraints.maxWidth > 600) {
          gridCount = 2;
        } else {
          gridCount = 1;
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            childAspectRatio: 3 / 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: passengers.length,
          itemBuilder: (context, index) {
            return PassengerCard(passenger: passengers[index]);
          },
        );
      },
    );
  }
}

class PassengerCard extends StatelessWidget {
  final Passenger passenger;

  PassengerCard({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              passenger.passengerName[0],
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  passenger.passengerName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(passenger.passengerPhoneNumber),
                Text(passenger.passengerBio,style: TextStyle(fontSize: 10),),
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'update') {
                // Update passenger data
              } else if (value == 'delete') {
                // Delete passenger data
              } else if (value == 'rides') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RidesDetailScreen(uid: passenger.uidp,),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'update',
                child: Text('Update Data'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete Passenger'),
              ),
              PopupMenuItem(
                value: 'rides',
                child: Text('Rides Details'),
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

class RidesDetailScreen extends StatelessWidget {
  final String uid;
  RidesDetailScreen({required this.uid});
  @override
  Widget build(BuildContext context) {
    final ref=FirebaseDatabase.instance.ref("PassengerTrips").child(uid);
    return Scaffold(
      appBar: AppBar(
        title: Text('Rides Details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
      ),
      body: FirebaseAnimatedList(
        query: ref,
        itemBuilder: ((context, snapshot, animation, index){
          return Card(
            color: Colors.grey[200],
            child: ListTile(
              title: Row(
                children: [
                  Text("Date: ${snapshot.child('date').value.toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text('Person: '),
                  Container(
                    width: 20,
                    height: 20,
                    color: Colors.grey,
                    child: Center(
                      child: Text(
                        snapshot.child('person').value.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(children: [
                Text("From: ",style: TextStyle(fontWeight: FontWeight.bold)),
                Text(snapshot.child('location/from').value.toString()),
                Text("   To: ",style: TextStyle(fontWeight: FontWeight.bold),),
                Text(snapshot.child('location/to').value.toString()),
              ],),

            ),
          );
        }),
      )
    );
  }
}

class Passenger {
  final String deviceToken;
  final String passengerBio;
  final String passengerCreatedAt;
  final String passengerGender;
  final String passengerName;
  final String passengerPhoneNumber;
  final String uidp;

  Passenger({
    required this.deviceToken,
    required this.passengerBio,
    required this.passengerCreatedAt,
    required this.passengerGender,
    required this.passengerName,
    required this.passengerPhoneNumber,
    required this.uidp,
  });

  factory Passenger.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Passenger(
      deviceToken: data['deviceToken'],
      passengerBio: data['passengerBio'],
      passengerCreatedAt: data['passengerCreatedAt'],
      passengerGender: data['passengerGender'],
      passengerName: data['passengerName'],
      passengerPhoneNumber: data['passengerPhoneNumber'],
      uidp: data['uidp'],
    );
  }
}
