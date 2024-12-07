import 'package:didiportal/Dashboard/rides/Google_map.dart';
import 'package:didiportal/Helpers/Globle_variables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../Helpers/custom.dart';

class Rides extends StatefulWidget {
  @override
  _RidesState createState() => _RidesState();
}

class _RidesState extends State<Rides> {
  String selectedRoute = 'ParachinarToIslamabad';
  late DatabaseReference databaseRef;

  @override
  void initState() {
    super.initState();
    databaseRef = FirebaseDatabase.instance.ref('FromTo/$selectedRoute');
  }

  void updateDatabaseReference(String route) {
    setState(() {
      selectedRoute = route;
      databaseRef = FirebaseDatabase.instance.ref('FromTo/$route');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: selectedRoute,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black, size: 24),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.black, fontSize: 15),
              dropdownColor: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              underline: Container(
                height: 2,
                color: Colors.black38,
              ),
              items: <String>[
                'ParachinarToIslamabad',
                'IslamabadToParachinar',
                'ParachinarToPeshawar',
                'PeshawarToParachinar',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRoute = newValue!;
                });
                updateDatabaseReference(newValue!);
              },
            ),
          ),
        ],
      ),
      body: FirebaseAnimatedList(
        key: ValueKey<String>(selectedRoute),
        query: databaseRef,
        itemBuilder: (context, snapshot, animation, index) {
          if (snapshot.child('onPortal').value.toString() == "true") {
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                trailing: PopupMenuButton<String>(
                  onSelected: (select) {
                    // Logic 
                  },
                  itemBuilder: (BuildContext context) {
                    return {'Remove', 'Locate'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
                leading: snapshot.child('profilePic').value != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                            snapshot.child('profilePic').value.toString()),
                        radius: 30,
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 30,
                      ),
                title: Text(
                  snapshot.child('name').value.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.child('DriverPhoneNumber').value.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                        'Car: ${snapshot.child('carColor').value.toString()} ${snapshot.child('carYear').value.toString()}'),
                    Row(
                      children: [
                        Text(
                            'Seats: ${snapshot.child('seats').value.toString()}'),
                        Text(
                            '   Fare: ${snapshot.child('fear').value.toString()}'),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                            'Pick: ${snapshot.child('pick').value.toString()}'),
                        Text(
                            '  Drop: ${snapshot.child('drop').value.toString()}'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Date: '),
                        Container(
                            height: 20,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: greyColor,
                            ),
                            child: Center(
                              child: Text(
                                snapshot.child('date').value.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            )),
                        Text('   Time:'),
                        Container(
                          height: 20,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: greyColor,
                          ),
                          child: Center(
                            child: Text(
                              snapshot.child('time').value.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(width: 1, color: Colors.black38)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                            'Comments: ${snapshot.child('comments').value.toString()}'),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        CustomButton(
                          onPressed: () {
                            showAddDriverDialog(context,
                                snapshot.child('uid').value.toString());
                          },
                          text: "Add passenger",
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        CustomButton(
                            text: "Passengers",
                            onPressed: () {
                              showPassengerListDialog(context,
                                  snapshot.child('uid').value.toString());
                            }),
                      ],
                    )
                  ],
                ),
                isThreeLine: true,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class AddDriverDialog extends StatefulWidget {
  final String uid;

  AddDriverDialog({required this.uid});

  @override
  _AddDriverDialogState createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<AddDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phoneNumber = '';
  String bio = '';
  LatLng? selectedLocation = LatLng(33.648167, 73.073069);
  int persons = 1;
  String? _selectedGender;
  String deviceToken = '';

  Future<void> _navigateToMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const PassengerMap(),
      ),
    );
    if (result != null) {
      setState(() {
        selectedLocation = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title:
          Text('Add Passenger', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                style: TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value!;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                style: TextStyle(fontSize: 12),
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Bio';
                  }
                  return null;
                },
                onSaved: (value) {
                  bio = value!;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: <Widget>[
                  RadioListTile<String>(
                    title: Text('Male'),
                    value: 'Male',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Female'),
                    value: 'Female',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToMap;
                  //    Navigator.push(context, MaterialPageRoute(builder: (context)=>PassengerMap()));
                },
                child: Text("select location"),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Persons: $persons', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (persons > 1) {
                            setState(() {
                              persons--;
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            persons++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Add Passenger',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blueAccent,
                      ),
                    ),
                    content: Text(
                      'Do you want to add a passenger?',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Handle Yes action

                          var timestamp = DateTime.now().millisecondsSinceEpoch;

                          DatabaseReference ref = FirebaseDatabase.instance
                              .ref("DriversHavingPassengerData")
                              .child(widget.uid);
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // Add driver data saving logic here
                            ref.child(timestamp.toString()).set({
                              "passengerBookSeats": persons.toString(),
                              "passengerName": name.toString(),
                              "passengerPhone": phoneNumber.toString(),
                              "location": {
                                "lat": selectedLocation!.latitude.toDouble(),
                                "long": selectedLocation!.longitude.toDouble(),
                              },
                              "gender": _selectedGender.toString(),
                              "bio": bio.toString(),
                              "deviceToken": deviceToken
                            });

                            Navigator.of(context).pop();
                          }
                          Navigator.of(context).pop(); // Close the dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Passenger Added')),
                          );
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Handle No action
                          Navigator.of(context).pop(); // Close the dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No Passenger Added')),
                          );
                        },
                        child: Text(
                          'No',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}

void showAddDriverDialog(BuildContext context, uid) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddDriverDialog(
        uid: uid,
      );
    },
  );
}

void showPassengerListDialog(BuildContext context, uid) {
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref('DriversHavingPassengerData').child(uid);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Passenger List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: FirebaseAnimatedList(
            query: ref,
            itemBuilder: (context, snapshot, animation, index) {

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        snapshot.child('passengerName').value.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(snapshot.child('passengerPhone').value.toString(), style: TextStyle(fontSize: 16)),
                          Text('Gender: ${snapshot.child('gender').value.toString()}', style: TextStyle(fontSize: 14)),
                          Text('Bio: ${snapshot.child('bio').value.toString()}', style: TextStyle(fontSize: 12)),
                          Text('Booked Seats: ${snapshot.child('passengerBookSeats').value.toString()}', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Location') {
                            // Handle location action
                            print('Location action');
                          } else if (value == 'Remove') {
                            // Handle remove action
                            ref.child(snapshot.key!).remove();
                            print('Remove action');
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Location', 'Remove'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        icon: Icon(Icons.more_vert),
                      ),
                      onTap: () {
                       //
                      },
                    ),
                  ),
                );


            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      );
    },
  );
}
