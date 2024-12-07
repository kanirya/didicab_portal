import 'package:flutter/material.dart';

class logInScreen extends StatefulWidget {
  const logInScreen({super.key});

  @override
  State<logInScreen> createState() => _logInScreenState();
}

class _logInScreenState extends State<logInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Color(0xffF0F3FA),
      body: Center(
        child: Container(
          width: 300,
          height: 450,
          color: Colors.white,
          child: Column(
            children: [
              Container(height: 70,color: Colors.red,
              )
            ],
          ),

        ),
      ),
    );
  }
}
