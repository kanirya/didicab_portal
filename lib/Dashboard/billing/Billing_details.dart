import 'package:didiportal/Models/driver_model.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverBillingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Billing'),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('DriverBilling').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          Map<dynamic, dynamic> billingData =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          return FutureBuilder(
            future: Future.wait(billingData.keys
                .map((userId) => fetchDriverData(userId.toString()))
                .toList()),
            builder: (context,
                AsyncSnapshot<List<Map<String, dynamic>>> combinedSnapshot) {
              if (combinedSnapshot.hasError) {
                return Center(child: Text('Error: ${combinedSnapshot.error}'));
              }
              if (combinedSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              List<Map<String, dynamic>> driverBillingData =
                  combinedSnapshot.data!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 800) {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 3 / 1,
                    ),
                    itemCount: driverBillingData.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverDetailScreen(
                                driver: driverBillingData[index]['driver'],
                                billing: driverBillingData[index]['billing'],
                              ),
                            ),
                          );
                        },
                        child: DriverBillingTile(
                          driver: driverBillingData[index]['driver'],
                          billing: driverBillingData[index]['billing'],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DriverBillingTile extends StatelessWidget {
  final Driver driver;
  final Billing billing;

  DriverBillingTile({required this.driver, required this.billing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(driver.profilePic),
            onBackgroundImageError: (_, __) => Icon(Icons.error),
            radius: 30,
          ),
          title: Text(
            driver.name,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(driver.phoneNumber),
              Text('Billing Amount: Rs ${billing.billingAmount}'),
              Text('Total Trips: ${billing.totalTrips}'),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return UpdateBillingDialog(
                    userId: driver.id,
                    currentBillingAmount: billing.billingAmount,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchDriverData(String userId) async {
  DocumentSnapshot driverSnapshot =
      await FirebaseFirestore.instance.collection('drivers').doc(userId).get();
  Driver driver = Driver.fromFirestore(driverSnapshot);

  DataSnapshot billingSnapshot =
      await FirebaseDatabase.instance.ref('DriverBilling/$userId').get();
  Billing billing = Billing.fromRealtimeDatabase(billingSnapshot);

  return {'driver': driver, 'billing': billing};
}

class UpdateBillingDialog extends StatefulWidget {
  final String userId;
  final double currentBillingAmount;

  UpdateBillingDialog(
      {required this.userId, required this.currentBillingAmount});

  @override
  _UpdateBillingDialogState createState() => _UpdateBillingDialogState();
}

class _UpdateBillingDialogState extends State<UpdateBillingDialog> {
  final _formKey = GlobalKey<FormState>();
  double _billingAmount = 0;
  double _netAmount=0;

  @override
  void initState() {
    super.initState();
    _netAmount = widget.currentBillingAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Received  Amount'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: InputDecoration(labelText: 'Received Amount'),
          keyboardType: TextInputType.number,
          initialValue: _billingAmount.toString(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a Received amount';
            }
            return null;
          },
          onSaved: (value) {
            _billingAmount = double.parse(value!);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Update Amount"),
                    content: Text("Do you want to update payment?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("No"),
                      ),
                      TextButton(
                        onPressed: () {
                          FirebaseDatabase.instance
                              .ref('DriverBilling/${widget.userId}')
                              .update({
                            'billingAmount': _netAmount-_billingAmount,
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text("Yes"),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}

class DriverDetailScreen extends StatelessWidget {
  final Driver driver;
  final Billing billing;

  DriverDetailScreen({required this.driver, required this.billing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(driver.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(driver.profilePic),
              onBackgroundImageError: (_, __) => Icon(Icons.error),
              radius: 50,
            ),
            SizedBox(height: 10),
            Text(
              driver.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(driver.phoneNumber),
            SizedBox(height: 10),
            Text('Billing Amount: Rs ${billing.billingAmount}'),
            Text('Total Trips: ${billing.totalTrips}'),
            SizedBox(height: 10),
            Text('CNIC: ${driver.CNIC}'),
            Text(
                'Car: ${driver.carYear} ${driver.carColor} ${driver.make} ${driver.model}'),
            Text('Number Plate: ${driver.numberPlate}'),
            Text('Seats: ${driver.seats}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DriverTripsScreen(driverId: driver.id),
                  ),
                );
              },
              child: Text('View Trips'),
            ),
          ],
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
