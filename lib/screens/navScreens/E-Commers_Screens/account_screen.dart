
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../E-commers Screen/navScreens/defaultScreen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? user;
  String userName = "Loading...";
  String userEmail = "Loading...";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userEmail = user!.email ?? "No email";
        userName = user!.displayName ?? "User";
        profileImageUrl = user!.photoURL ?? "";
      });

      // You might want to fetch additional user data from Firestore here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue[100],
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : null,
              child: profileImageUrl.isEmpty
                  ? Icon(Icons.person, size: 60, color: Colors.blue[800])
                  : null,
            ),
            SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 30),
            _buildAccountOption(
              icon: Icons.medical_services,
              title: "My Medications",
              onTap: () {
                // Navigate to medications screen
              },
            ),
            _buildAccountOption(
              icon: Icons.notifications,
              title: "Reminder Settings",
              onTap: () {
                // Navigate to reminder settings
              },
            ),
            _buildAccountOption(
              icon: Icons.history,
              title: "Dose History",
              onTap: () {
                // Navigate to history screen
              },
            ),
            _buildAccountOption(
              icon: Icons.settings,
              title: "App Settings",
              onTap: () {
                // Navigate to settings screen
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Defaultscreen()));
                // Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Sign Out",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue[800],
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}