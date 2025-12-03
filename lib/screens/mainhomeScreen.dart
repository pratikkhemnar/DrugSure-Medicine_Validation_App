import 'package:drugsuremva/E-commers%20Screen/E_HomeScreen.dart';
import 'package:drugsuremva/E-commers%20Screen/navScreens/profile_screen.dart';
import 'package:drugsuremva/screens/navScreens/startDefaultScreen.dart';
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

  // Define your pages here. Ensure these classes exist and are imported correctly.
  final List<Widget> navePages = [
    StartDefaultScreen(),         // Index 0: Home
    UnderWorking(),                // Index 1: E-Commerce
    AdverseEventReportScreen(),   // Index 2: Report
    ProfileScreen()               // Index 3: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This switches the body automatically based on chosenIndex
      body: navePages[chosenIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Added for better stability with 4+ items
        currentIndex: chosenIndex,
        onTap: (index) {
          // CORRECTED: Just update the index. No need to Navigator.push here
          // because the body above will update automatically.
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