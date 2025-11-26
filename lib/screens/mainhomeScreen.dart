// lib/screens/mainhomeScreen.dart
import 'package:drugsuremva/E-commers%20Screen/E_HomeScreen.dart';
import 'package:drugsuremva/E-commers%20Screen/navScreens/defaultScreen.dart';
import 'package:drugsuremva/E-commers%20Screen/navScreens/profile_screen.dart';
import 'package:drugsuremva/screens/navScreens/startDefaultScreen.dart';
import 'package:drugsuremva/screens/navScreens/report_screen/reportScreen.dart';
import 'package:flutter/material.dart';

import 'navScreens/report_screen/adverse_event_report_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int chosenIndex = 0;

  final List<Widget> navePages = [
    StartDefaultScreen(),
    EHomescreen(),
    AdverseEventReportScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navePages[chosenIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: chosenIndex,
        onTap: (index) {
          setState(() {
            chosenIndex = index;
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EHomescreen()));
            }
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_max_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: "E-Commerce"),
          BottomNavigationBarItem(icon: Icon(Icons.report_gmailerrorred_outlined), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_outlined), label: "Profile"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/doctor-list');
        },
        icon: const Icon(Icons.medical_services),
        label: const Text('Doctor Consult'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
