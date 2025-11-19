import 'package:drugsuremva/E-commers%20Screen/E_HomeScreen.dart';
import 'package:drugsuremva/E-commers%20Screen/providers/user_provider_screen.dart';
import 'package:drugsuremva/auth/check_user_status_Screen.dart';
import 'package:drugsuremva/auth/createAccount.dart';
import 'package:drugsuremva/screens/mainhomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider(),)
      ],
      child: MaterialApp(
        title: 'Medicine E-Commece App',
        theme: ThemeData(
          useMaterial3: true
        ),
        routes: {
          "/login":(context) => Login(),
          "/signup": (context) =>Createaccount(),
          "ehome":(context) => EHomescreen(),
          "/mainhomescreen" : (context) => Homescreen()
        },
        debugShowCheckedModeBanner: false,
        home: Login(),   // add const if LoginScreen is const constructor
      ),
    );
  }
}
