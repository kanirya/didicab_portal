
import 'package:didiportal/utils/constants.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatefulWidget {
  @override
  _ResponsiveLayoutState createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedScreenIndex = 0;

  final List<Widget> _screens = [
    ScreenOne(),
    ScreenTwo(),
    ScreenThree(),
    ScreenFour(),
    ScreenFive(),
  ];

  void _onMenuSelect(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
    // Close the drawer in tablet mode when a menu item is clicked
    if (MediaQuery.of(context).size.width <= 600) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrLarger = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Row(
          children: [
            Text(
              'DIDIrooms',
              style: TextStyle(
                color: accentColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: isTabletOrLarger
          ? null
          : SizedBox(
        width: 240, // Set custom drawer width
        child: Drawer(
          child: Menu(
            onSelect: _onMenuSelect,
            selectedScreenIndex: _selectedScreenIndex,
          ),
        ),
      ),
      body: Row(
        children: [
          if (isTabletOrLarger)
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: secondaryColor, // Updated to a pleasing green
              ),
              child: Menu(
                onSelect: _onMenuSelect,
                selectedScreenIndex: _selectedScreenIndex,
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _screens[_selectedScreenIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class Menu extends StatelessWidget {
  final Function(int) onSelect;
  final int selectedScreenIndex;

  Menu({required this.onSelect, required this.selectedScreenIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              _buildMenuItem(Icons.home, 'Home', 0),
              _buildMenuItem(Icons.business, 'Business', 1),
              _buildMenuItem(Icons.school, 'School', 2),
              _buildMenuItem(Icons.settings, 'Settings', 3),
              _buildMenuItem(Icons.contact_mail, 'Contact Us', 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    return Container(
      width: 70,
      child: ListTile(
        leading: Icon(
          icon,
          color: selectedScreenIndex == index ? Colors.white : accentColor,
          size: 25,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: selectedScreenIndex == index ? Colors.white : accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: selectedScreenIndex == index,
        selectedTileColor: secondaryColor,
        onTap: () => onSelect(index),
      ),
    );
  }
}

// Screens
class ScreenOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text(
          'Screen One',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ),
    );
  }
}

class ScreenTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text(
          'Screen Two',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ),
    );
  }
}

class ScreenThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text(
          'Screen Three',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ),
    );
  }
}

class ScreenFour extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text(
          'Screen Four',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ),
    );
  }
}

class ScreenFive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text(
          'Screen Five',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
      ),
    );
  }
}