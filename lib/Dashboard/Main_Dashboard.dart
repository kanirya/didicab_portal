import 'package:didiportal/Dashboard/OnRoad/onRoads_ride.dart';
import 'package:didiportal/Dashboard/Passenger.details.dart';
import 'package:didiportal/Dashboard/accounting/accounting_dashboard.dart';
import 'package:didiportal/Dashboard/billing/Billing_details.dart';
import 'package:didiportal/Dashboard/driver_detials.dart';
import 'package:didiportal/Dashboard/rides/Rides.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _currentScreen = ResponsiveDashboard();

  void _navigateTo(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
    _scaffoldKey.currentState?.openEndDrawer(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(onMenuItemSelected: _navigateTo),
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
          CircleAvatar(
            child: Icon(Icons.person),
          ),
        ],
      ),
      body: _currentScreen,
    );
  }
}


class SideMenu extends StatelessWidget {
  final Function(Widget) onMenuItemSelected;

  SideMenu({required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  text: 'Dashboard',
                  onTap: () {
                    onMenuItemSelected(ResponsiveDashboard());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.directions_car,
                  text: 'Rides',
                  onTap: () {
                    onMenuItemSelected(Rides());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.cable_rounded,
                  text: 'On Road Rides',
                  onTap: () {
                    onMenuItemSelected(onRoadRides());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.person,
                  text: 'Drivers',
                  onTap: () {
                    onMenuItemSelected(DriverScreen());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  text: 'Passengers',
                  onTap: () {
                    onMenuItemSelected(PassengerScreen());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.payment,
                  text: 'Payments',
                  onTap: () {
                    onMenuItemSelected(DriverBillingScreen());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_sharp,
                  text: 'Accounts',
                  onTap: () {
                    onMenuItemSelected(AccountingDashboard());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.report,
                  text: 'Complains',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.work,
                  text: 'Employees',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.supervisor_account,
                  text: 'Users',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      hoverColor: Colors.blue.shade100,
    );
  }
}

class ResponsiveDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return WideDashboard();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return MediumDashboard();
        } else {
          return NarrowDashboard();
        }
      },
    );
  }
}

class WideDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Wide Dashboard'),
    );
  }
}

class MediumDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Medium Dashboard'),
    );
  }
}

class NarrowDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Narrow Dashboard'),
    );
  }
}

class RidesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('rides').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var rides = snapshot.data?.docs;
        return ListView.builder(
          itemCount: rides?.length,
          itemBuilder: (context, index) {
            var ride = rides?[index];
            return ListTile(
              title: Text(ride?['pickup']),
              subtitle: Text(ride?['destination']),
            );
          },
        );
      },
    );
  }
}
