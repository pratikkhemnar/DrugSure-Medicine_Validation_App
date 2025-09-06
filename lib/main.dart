import 'package:drugsuremva/E-commers%20Screen/E_HomeScreen.dart';
import 'package:drugsuremva/auth/createAccount.dart';
import 'package:drugsuremva/screens/homeScreen.dart';
import 'package:drugsuremva/screens/login%20screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Make sure binding is initialized
  await Firebase.initializeApp();             // Initialize Firebase first
  runApp(const MyApp());                      // Then run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine E-Commece App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      routes: {
        "/login":(context) => Login(),
        "/signup": (context) =>Createaccount(),
        "ehome":(context) => EHomescreen()
      },
      debugShowCheckedModeBanner: false,
      home: Login(),   // add const if LoginScreen is const constructor
    );
  }
}
