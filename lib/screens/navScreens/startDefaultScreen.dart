import 'package:carousel_slider/carousel_slider.dart';
import 'package:drugsuremva/screens/OurServices_screen/ConsultHomeScreen/chat_screen.dart';
import 'package:drugsuremva/under_working.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../OurServices_screen/ConsultHomeScreen/videocall_screen.dart';
import '../quick_Actions_Screens/barcodes_screen/entry_page.dart';
import '../quick_Actions_Screens/symptom_checker_screen.dart';
import '../quick_Actions_Screens/healthInfoScreen.dart';
import '../quick_Actions_Screens/nearbypharma.dart';

class StartDefaultScreen extends StatefulWidget {
  const StartDefaultScreen({super.key});

  @override
  State<StartDefaultScreen> createState() => _StartDefaultScreenState();
}

class _StartDefaultScreenState extends State<StartDefaultScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  final List<String> _carouselImages = [
    'assets/images/img1.jpg',
    'assets/images/img2.jpg',
    'assets/images/img3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DrugSure",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(

        // ****************************** BODY ********************************
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome to DrugSure!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Verify your medicines for safety",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Section
                  _buildSectionTitle("Quick Actions"),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildCarouselSlider(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Our Services"),
                  const SizedBox(height: 12),
                  _buildServices(context),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                // 🔎 Implement search functionality
              },
              decoration: InputDecoration(
                hintText: "Search medicines...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.teal, size: 24),
                  onPressed: () {
                    // 🔎 Implement search functionality
                  },
                ),

                // ✅ FIXED alignment for mic + QR icons
                suffixIcon: SizedBox(
                  width: 96, // enough space for 2 icons
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: _isListening ? Colors.red : Colors.teal,
                          size: 24,
                        ),
                        onPressed: () {
                          if (_isListening) {
                            _stopListening();
                          } else {
                            _startListening();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner,
                            color: Colors.teal, size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrCodeScanning(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  //*********************** Section title **********************
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

//*********************** Actions Cards **********************

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.8,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildActionButton(
          icon: FontAwesomeIcons.barcode,
          color: Colors.blue,
          label: "Scan",
          onTap: () => _navigateToBarcodeScanner(context),
        ),

        _buildActionButton(
          icon: Icons.local_pharmacy,
          color: Colors.orange,
          label: "Pharmacies",
          onTap: () => _navigateToNearbyPharmacies(context),
        ),

        _buildActionButton(
          icon: Icons.add_photo_alternate,
          color: Colors.green,
          label: "Skin disease",
          onTap: () => _navigateToHealthNews(context),
        ),

        _buildActionButton(
          icon: Icons.search_off_outlined,
          color: Colors.purple,
          label: "Analysis",
          onTap: () => _symptomCheckerScreen(context),
        ),
      ],
    );
  }

  //*********************** Action Buttons **********************
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToBarcodeScanner(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => QrCodeScanning()));
  }

  void _navigateToHealthNews(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UnderWorking()));
  }

  void _navigateToNearbyPharmacies(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NearbyPharmaciesPro()));
  }

  void _symptomCheckerScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SymptomCheckerScreen()));
  }

  // Carouselider
  Widget _buildCarouselSlider() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          autoPlayInterval: const Duration(seconds: 5),
        ),
        items: _carouselImages.map((imagePath) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  //*********************** Services **********************

  Widget _buildOurServices(
      String name,
      String details,
      IconData icon,
      Color color,
      BuildContext context,
      Widget targetScreen,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon section
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 20, color: color ,),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        color: Colors.grey[800],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 6),
              // Details
              Text(
                details,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Action Button
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Explore",
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 12,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //*********************** Temporary **********************

  Widget _buildServices(BuildContext context) {
    return Container(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildOurServices(
            "Cosmetics",
            "For skin & beauty care",
            Icons.face,
            Colors.pinkAccent,
            context,
            HealthInformationPage(),
          ),
          _buildOurServices(
            "Consult",
            "Consult doctors online • 24x7 availability",
            Icons.phone_in_talk,
            Colors.teal,
            context,
            ChatScreen(currentUserId: FirebaseAuth.instance.currentUser!.uid, peerUserId: "UkA7mhZlz4Re1TPxs8thpXHAH5R2"), // or replace with a specific screen for Teleconsultancy
          ),
          _buildOurServices(
            "Health Service",
            "Consultations • Lab Tests • Home Care",
            Icons.medical_services, // More relevant icon for health services
            Colors.teal, // Consistent with medical theme
            context,
            HealthInformationPage(),

            //ConsultScreen(peerUserId: 'UkA7mhZlz4Re1TPxs8thpXHAH5R2', peerName: 'DR.Vaibhav',), // Navigates to your Health Services screen
          ),
        ],
      ),
    );
  }

}
