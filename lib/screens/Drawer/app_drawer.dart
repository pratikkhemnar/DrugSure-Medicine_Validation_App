import 'package:drugsuremva/add_medicine_data.dart';
import 'package:drugsuremva/auth/login.dart';
import 'package:drugsuremva/screens/Drawer/appAboutScreen.dart';
import 'package:drugsuremva/screens/Drawer/supportScreen.dart';
import 'package:drugsuremva/screens/navScreens/startDefaultScreen.dart';
import 'package:drugsuremva/under_working.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../Admin/screens/adminDashboard_screen.dart';
import '../../E-commers Screen/navScreens/profile_screen.dart';
import 'notification_screen.dart';

class AppDrawer extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          _buildMenuItems(context),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A5C5A), Color(0xFF0A7A78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      currentAccountPicture: GestureDetector(
        onTap: () => _navigateTo(context, const ProfileScreen()),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 45, color: Colors.grey.shade700),
        ),
      ),
      accountName: Text(
        _getUserName(),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        user?.email ?? "guest@example.com",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      _MenuItem(Icons.admin_panel_settings, "Admin Pannel",  AdminDashboardScreen()),
      _MenuItem(Icons.home_filled, "Home", const StartDefaultScreen()),
      _MenuItem(Icons.headset_mic, "Support", const SupportScreen()),
      _MenuItem(Icons.notifications, "Notifications", const NotificationScreen()),
      _MenuItem(Icons.settings, "Settings", const UnderWorking(),
          trailing: Icons.dark_mode_rounded),
      _MenuItem(Icons.share, "Share App", null, isAction: true),
      _MenuItem(Icons.info_rounded, "About", const AboutScreen()),
      _MenuItem(Icons.add, "Add Medicine",  AddMedicineScreen()),


    ];

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item.icon, color: const Color(0xFF0A5C5A), size: 26),
            title: Text(item.text, style: _menuTextStyle),
            trailing: item.trailing != null
                ? Icon(item.trailing, color: Colors.grey.shade600)
                : null,
            onTap: () => item.isAction ? _shareApp() : _navigateTo(context, item.screen!),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text("Logout", style: TextStyle(fontSize: 16)),
        onPressed: () => _confirmLogout(context),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _shareApp() {
    Share.share('Check out DrugSure - Your trusted pharmacy partner! https://play.google.com/store/apps/details?id=com.yourcompany.drugsure');
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _performLogout(context),
            child: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackbar(context, 'Logout failed: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getUserName() {
    if (user?.displayName?.isNotEmpty == true) return user!.displayName!;
    if (user?.email != null) return user!.email!.split('@')[0];
    return "DrugSure User";
  }

  final TextStyle _menuTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

class _MenuItem {
  final IconData icon;
  final String text;
  final Widget? screen;
  final IconData? trailing;
  final bool isAction;

  _MenuItem(this.icon, this.text, this.screen, {
    this.trailing,
    this.isAction = false
  });
}

