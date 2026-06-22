// lib/main.dart
import 'package:drugsuremva/auth/AdminAccount.dart';
import 'package:drugsuremva/auth/createAccount.dart';
import 'package:drugsuremva/drugsure_ecommerce/screens/medicine_store_screen.dart';
import 'package:drugsuremva/screens/mainhomeScreen.dart';
import 'package:drugsuremva/auth/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_dashboard/admin_dashboard_screen.dart';
import 'auth/splashScreen.dart';
import 'drugsure_ecommerce/providers/cart_provider.dart';
import 'drugsure_ecommerce/providers/user_provider_screen.dart';
import 'screens/Drawer/setting/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Medicine Validation App',
            themeMode: settings.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: settings.accentColor,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: settings.accentColor,
              brightness: Brightness.dark,
            ),
            routes: {
              "/login": (context) => Login(),
              "/signup": (context) => Createaccount(),
              "ehome": (context) => MedicineStoreScreen(),
              "/mainhomescreen": (context) => Homescreen(),
              "/createAdmin" :(context) => CreateAdminAccount(),
              "/adminDashboard" : (context) => AdminDashboardScreen(),
              // add other routes here as needed
            },
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.textScaleFactor),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
