// ============================================================
// FILE: INTEGRATION_GUIDE.md  (READ THIS FIRST)
// ============================================================

/*
╔══════════════════════════════════════════════════════════════╗
║          DRUGSURE ECOMMERCE MODULE - INTEGRATION GUIDE       ║
╚══════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 1: FOLDER STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Copy these folders into your existing lib/ folder:

lib/
├── main.dart              ← existing
├── dashboard_screen.dart  ← existing
├── models/
│   ├── medicine_model.dart  ← NEW
│   └── order_model.dart     ← NEW (contains Address, Order, CartItem, OrderItem)
├── providers/
│   └── cart_provider.dart   ← NEW (contains CartProvider + WishlistProvider)
├── services/
│   └── medicine_service.dart ← NEW (MedicineService + OrderService + AddressService)
├── screens/
│   ├── medicine_store_screen.dart   ← NEW  (main shop)
│   ├── product_detail_screen.dart   ← NEW
│   ├── cart_screen.dart             ← NEW
│   ├── checkout_screen.dart         ← NEW
│   ├── add_address_screen.dart      ← NEW
│   ├── payment_screen.dart          ← NEW
│   └── orders_screen.dart           ← NEW (contains OrderConfirmationScreen + OrdersScreen)
└── widgets/
    └── medicine_card.dart           ← NEW

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 2: pubspec.yaml - ADD THESE DEPENDENCIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dependencies:
  flutter:
    sdk: flutter
  
  # ALREADY HAVE (Firebase)
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0
  
  # ADD THESE NEW ONES:
  provider: ^6.1.1           # State management for cart
  razorpay_flutter: ^1.3.7   # Payment gateway
  http: ^1.2.0               # REST API calls (if using REST instead of Firestore)
  shared_preferences: ^2.2.2  # Local storage for addresses

Run: flutter pub get

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 3: main.dart - WRAP WITH MULTIPROVIDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'DrugSure',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const DashboardScreen(), // your existing home
      ),
    );
  }
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 4: DASHBOARD - ADD NAVIGATE BUTTON
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

In your dashboard_screen.dart, add this button/card:

import 'screens/medicine_store_screen.dart';
import 'screens/orders_screen.dart';

// SHOP BUTTON:
ElevatedButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const MedicineStoreScreen()),
  ),
  child: const Text('Buy Medicines'),
),

// MY ORDERS BUTTON:
ElevatedButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const OrdersScreen()),
  ),
  child: const Text('My Orders'),
),

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 5: API CHANGE POINTS (WHERE TO ADD APIs)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FILE: services/medicine_service.dart
  • MedicineService.getAllMedicines()      → Line 40: Uncomment Firestore/REST code
  • MedicineService.searchMedicines()     → Line 60: Add Firestore query
  • OrderService.placeOrder()            → Line 120: Uncomment Firestore save
  • OrderService.getUserOrders()         → Line 135: Uncomment Firestore fetch
  • AddressService.getUserAddresses()    → Line 165: Uncomment Firestore fetch
  • AddressService.saveAddress()         → Line 175: Uncomment Firestore save

FILE: screens/payment_screen.dart
  • Line 30: Replace 'YOUR_RAZORPAY_KEY' with real key
  • Line 45-70: Uncomment Razorpay event handlers
  • Line 75-90: Uncomment _openRazorpay options

FILE: screens/checkout_screen.dart
  • Line 35: Replace 'user123' with FirebaseAuth.instance.currentUser?.uid

FILE: screens/orders_screen.dart (OrdersScreen class)
  • Line 30: Replace 'user123' with actual userId

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 6: FIRESTORE COLLECTIONS STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Firestore:
├── medicines/           (collection)
│   └── {docId}/        each = Medicine.toJson()
│
├── orders/             (collection)
│   └── {orderId}/      each = Order.toJson()
│
└── users/              (collection)
    └── {userId}/
        ├── addresses/  (subcollection)
        │   └── {addrId}/ each = Address.toJson()
        └── orders/     (subcollection, for quick user order lookup)
            └── {orderId}/ {orderId, createdAt}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STEP 7: RAZORPAY SETUP (ANDROID)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

In android/app/build.gradle, ensure minSdkVersion >= 19:
  defaultConfig {
    minSdkVersion 19
  }

In AndroidManifest.xml add:
  <activity android:name="com.razorpay.CheckoutActivity"
    android:theme="@style/Checkout"/>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SCREEN NAVIGATION FLOW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Dashboard
  ↓
MedicineStoreScreen  (browse/search)
  ↓
ProductDetailScreen  (tap medicine card)
  ↓
CartScreen           (cart icon or FAB)
  ↓
CheckoutScreen       (proceed to checkout)
  ↓
PaymentScreen        (place order)
  ↓
OrderConfirmationScreen
  ↓
OrdersScreen         (track orders)

*/

// ============================================================
// QUICK DASHBOARD WIDGET - Copy this card into your dashboard
// ============================================================

/*

// ADD THESE IMPORTS TO YOUR DASHBOARD SCREEN:

import 'package:provider/provider.dart';
import 'screens/medicine_store_screen.dart';
import 'screens/orders_screen.dart';
import 'providers/cart_provider.dart';

// ADD THIS WIDGET ANYWHERE IN YOUR DASHBOARD BODY:

Widget _buildEcommerceSection(BuildContext context) {
  final cart = context.watch<CartProvider>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MedicineStoreScreen())),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_pharmacy, color: Colors.white, size: 32),
                    const SizedBox(height: 12),
                    const Text('Buy Medicines',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    if (cart.itemCount > 0)
                      Text('${cart.itemCount} in cart',
                          style: TextStyle(color: Colors.white.withOpacity(0.8),
                              fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen())),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.receipt_long, color: Colors.white, size: 32),
                    SizedBox(height: 12),
                    Text('My Orders',
                        style: TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Track & manage',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

*/
