import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Dashboard/Main_Dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:const FirebaseOptions(
      apiKey: "AIzaSyDyUhTKNFFDmfUJkCrJ8v5656dd53Abt0Q",
      authDomain: "didi-auth.firebaseapp.com",
      databaseURL: "https://didi-auth-default-rtdb.firebaseio.com",
      projectId: "didi-auth",
      storageBucket: "didi-auth.appspot.com",
      messagingSenderId: "168767102842",
      appId: "1:168767102842:web:8b8fa518b38424aab3c0c3",
      measurementId: "G-NRNDXZ5RYZ"

    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'didicab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DashboardPage(),
    );
  }
}
