import 'package:drugsuremva/E-commers%20Screen/E_HomeScreen.dart';
import 'package:drugsuremva/E-commers%20Screen/navScreens/profile_screen.dart';
import 'package:drugsuremva/auth/profileScreen.dart';
import 'package:drugsuremva/screens/navScreens/E-Commers_Screens/dashboard_screen.dart';
import 'package:drugsuremva/screens/navScreens/default_screen/startDefaultScreen.dart';
import 'package:drugsuremva/under_working.dart';
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
    StartDefaultScreen(),         // Index 0: Home
    DashboardScreen(),                // Index 1: E-Commerce
    AdverseEventReportScreen(),   // Index 2: Report
    ProfileScreens()               // Index 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: navePages[chosenIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: chosenIndex,
        onTap: (index) {
          setState(() {
            chosenIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: "E-Commerce"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.report_gmailerrorred_outlined),
              label: "Report"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile"
          ),
        ],
      ),
    );
  }
}