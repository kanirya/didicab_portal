import 'package:flutter/material.dart';

class AccountingDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return WideDashboard();
        } else if (constraints.maxWidth > 700 && constraints.maxWidth < 1200) {
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        children: [
          TopBar(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Revenue(
                  width: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MediumDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        children: [
          TopBar(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Revenue(
                  width: 0.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NarrowDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        children: [
          TopBar(),
          Row(
            children: [
              Revenue(
                width: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Revenue extends StatefulWidget {
  final double width;

  const Revenue({super.key, required this.width});

  @override
  State<Revenue> createState() => _RevenueState();
}

class _RevenueState extends State<Revenue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widget.width,
      height: 200,
      child:const Card(
        color: Colors.white,
        shadowColor: Colors.black,
        child:Stack(
          children: [
                Positioned(
                  bottom: 4,
                  right: 40,
                  child: Text("hello"),
                ),

          ],
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30,
      decoration:
          BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.black26)),
    );
  }
}
