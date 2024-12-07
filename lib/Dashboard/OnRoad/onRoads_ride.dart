import 'package:didiportal/Dashboard/rides/Rides.dart';
import 'package:didiportal/Helpers/Globle_variables.dart';
import 'package:didiportal/Helpers/custom.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class onRoadRides extends StatefulWidget {
  const onRoadRides({super.key});

  @override
  State<onRoadRides> createState() => _onRoadRidesState();
}

class _onRoadRidesState extends State<onRoadRides> {
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

        title: Text('On Road Drivers',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: mainColor),),
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
          if(snapshot.child('onPortal').value.toString()=="false") {
            return Card(

              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                trailing: PopupMenuButton<String>(
                  onSelected: (select) {},
                  itemBuilder: (BuildContext context) {
                    return {'Remove', 'Locate'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
                leading: snapshot
                    .child('profilePic')
                    .value != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(
                      snapshot
                          .child('profilePic')
                          .value
                          .toString()),
                  radius: 30,
                )
                    : CircleAvatar(
                  child: Icon(Icons.person),
                  radius: 30,
                ),
                title: Text(
                  snapshot
                      .child('name')
                      .value
                      .toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot
                          .child('DriverPhoneNumber')
                          .value
                          .toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                        'Car: ${snapshot
                            .child('carColor')
                            .value
                            .toString()} ${snapshot
                            .child('carYear')
                            .value
                            .toString()}'),
                    Row(
                      children: [
                        Text(
                            'Seats: ${snapshot
                                .child('seats')
                                .value
                                .toString()}'),
                        Text(
                            '   Fare: ${snapshot
                                .child('fear')
                                .value
                                .toString()}'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Pick: ${snapshot
                            .child('pick')
                            .value
                            .toString()}'),
                        Text(
                            '  Drop: ${snapshot
                                .child('drop')
                                .value
                                .toString()}'),
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
                                snapshot
                                    .child('date')
                                    .value
                                    .toString(),
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
                              snapshot
                                  .child('time')
                                  .value
                                  .toString(),
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
                            'Comments: ${snapshot
                                .child('comments')
                                .value
                                .toString()}'),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        CustomButton(text: "Passengers", onPressed: () {
                          showPassengerListDialog(context,snapshot.child('uid').value.toString());
                        }),
                      ],
                    )
                  ],
                ),
                isThreeLine: true,
              ),
            );
          }else{
            return Container();
          }
        },
      ),
    );
  }
}
