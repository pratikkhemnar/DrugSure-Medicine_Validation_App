import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drugsuremva/screens/quick_Actions_Screens/barcodes_screen/screens/qr_scanner_screen.dart';
import 'package:drugsuremva/under_working.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Drawer/app_drawer.dart';
import '../Drawer/notification_screen.dart';
import '../OurServices_screen/doctor_consultancy/screens/doctor_list_screen.dart';
import '../quick_Actions_Screens/barcodes_screen/result_info_screen.dart';
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
  bool _isSearching = false;

  // --- Voice Search Logic ---
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
        });
        if (result.finalResult) {
          _stopListening();
          _performSearch(_searchController.text);
        }
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  // --- Search Logic ---
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final String searchLower = query.trim().toLowerCase();

    try {
      final firestore = FirebaseFirestore.instance;
      // Search by Batch
      final batchQuery = await firestore
          .collection('medicines')
          .where('batchNumberLower', isEqualTo: searchLower)
          .get();
      // Search by Brand Name (Prefix)
      final nameQuery = await firestore
          .collection('medicines')
          .where('brandNameLower', isGreaterThanOrEqualTo: searchLower)
          .where('brandNameLower', isLessThan: searchLower + '\uf8ff')
          .get();

      final Map<String, DocumentSnapshot> uniqueDocs = {};
      for (var doc in batchQuery.docs) uniqueDocs[doc.id] = doc;
      for (var doc in nameQuery.docs) uniqueDocs[doc.id] = doc;

      final results = uniqueDocs.values.toList();

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No medicine found for '$query'")));
      } else if (results.length == 1) {
        _navigateToResult(results.first.data() as Map<String, dynamic>);
      } else {
        _showSelectionSheet(results);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Search Error: $e")));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _navigateToResult(Map<String, dynamic> data) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MedicineResultScreen(data: data)));
  }

  void _showSelectionSheet(List<DocumentSnapshot> docs) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Medicine",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.medication, color: Colors.teal),
                      title: Text(data['brandName'] ?? 'Unknown'),
                      subtitle: Text("Batch: ${data['batchNumber'] ?? 'N/A'}"),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToResult(data);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speech.stop();
    super.dispose();
  }

  // ✅ UPDATED IMAGES: High quality medical theme images from Unsplash
  final List<Map<String, String>> _carouselItems = [

    {
      // Image: Medicine/Lab - Reliable
      "image": "https://images.pexels.com/photos/7289717/pexels-photo-7289717.jpeg",
      "title": "Verify Medicine",
      "subtitle": "Scan QR codes instantly to ensure authenticity."
    },
    {
      // Image: Medicine/Lab - Reliable
      "image": "https://images.unsplash.com/photo-1584017911766-d451b3d0e843?auto=format&fit=crop&w=800&q=80",
      "title": "Verify Medicine",
      "subtitle": "Scan QR codes instantly to ensure authenticity."
    },
    {
      "image": "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80",
      "title": "Expert Consultation",
      "subtitle": "Connect with top doctors 24/7."
    },
    {
      "image": "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?auto=format&fit=crop&w=800&q=80",
      "title": "Genuine Pharmacy",
      "subtitle": "Find trusted pharmacies near you."
    },
    {
      "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=800&q=80",
      "title": "Stay Healthy",
      "subtitle": "Get daily health tips and updates."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("DrugSure",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 🔔 NOTIFICATION ICON ADDED HERE
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen())
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                  'Check out DrugSure! Verify your medicines easily. Download now: https://play.google.com/store/apps/details?id=com.yourcompany.drugsure');
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // HEADER & SEARCH
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
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
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome to DrugSure!",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Verify your medicines for safety",
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                ],
              ),
            ),

            // MAIN CONTENT
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Quick Actions"),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  _buildCarouselSlider(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Our Services"),
                  const SizedBox(height: 12),
                  _buildServices(context),

                  // ================= REAL SECTIONS =================
                  const SizedBox(height: 30),

                  // 1. REGULATORY ALERTS (Vertical List)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Drug Alerts & Recalls"),
                      Text("See All",
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildRealAlertsList(),

                  const SizedBox(height: 30),

                  // 2. DAILY HEALTH TIPS (Vertical List - NO CARDS)
                  _buildSectionTitle("Daily Health Tips"),
                  const SizedBox(height: 12),
                  _buildRealHealthTips(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... [Previous Helper Widgets] ...
  // Keep all helper methods (_buildSearchBar, _buildQuickActions, _buildServices, _buildRealAlertsList, etc.) exactly as they were.


  // --- HELPER METHODS STUB (Replace with full code if copying fresh) ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _performSearch(value),
              decoration: InputDecoration(
                hintText: "Search name or batch no...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: _isSearching
                    ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.teal)))
                    : IconButton(
                    icon: const Icon(Icons.search,
                        color: Colors.teal, size: 24),
                    onPressed: () => _performSearch(_searchController.text)),
                suffixIcon: SizedBox(
                  width: 96,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: _isListening ? Colors.red : Colors.teal,
                            size: 24),
                        onPressed: () {
                          _isListening ? _stopListening() : _startListening();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner,
                            color: Colors.teal, size: 24),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UnderWorking())),
                      ),
                    ],
                  ),
                ),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal));
  }

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
            onTap: () => _navigateToBarcodeScanner(context)),
        _buildActionButton(
            icon: Icons.local_pharmacy,
            color: Colors.orange,
            label: "Pharmacies",
            onTap: () => _navigateToNearbyPharmacies(context)),
        _buildActionButton(
            icon: Icons.add_photo_alternate,
            color: Colors.green,
            label: "Skin disease",
            onTap: () => _navigateToHealthNews(context)),
        _buildActionButton(
            icon: Icons.search_off_outlined,
            color: Colors.purple,
            label: "Analysis",
            onTap: () => _symptomCheckerScreen(context)),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
        required Color color,
        required String label,
        required VoidCallback onTap}) {
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
                  color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 190,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
      ),
      items: _carouselItems.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Background Image
                Image.network(
                  item["image"]!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.teal,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),

                // 2. Gradient Overlay (For Text Readability)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),

                // 3. Text Content
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["subtitle"]!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToBarcodeScanner(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ScannerScreen()));
  }

  void _navigateToHealthNews(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => UnderWorking()));
    //Skin Disease
  }

  void _navigateToNearbyPharmacies(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NearbyPharmaciesPro()));
  }

  void _symptomCheckerScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SymptomCheckerScreen()));
  }

  Widget _buildServices(BuildContext context) {
    return Container(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildOurServices("Consult", "Consult doctors online • 24x7",
              Icons.phone_in_talk, Colors.teal, context, DoctorListScreen()),
          _buildOurServices("Cosmetics", "For skin & beauty care", Icons.face,
              Colors.pinkAccent, context, UnderWorking()),
          _buildOurServices("Health Service", "Tests • Home Care", Icons.medical_services, Colors.blue, context, HealthInformationPage()),
        ],
      ),
    );
  }

  Widget _buildOurServices(String name, String details, IconData icon,
      Color color, BuildContext context, Widget targetScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => targetScreen));
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
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: color.withOpacity(0.1), width: 1)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                              spreadRadius: 1)
                        ]),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              color: Colors.grey[800],
                              height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 16),
              Text(details,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[600], height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: color.withOpacity(0.2), width: 0.5)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text("Explore",
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 12, color: color)
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealAlertsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .orderBy('date', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error loading alerts"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("No current alerts. Stay safe!", style: TextStyle(color: Colors.grey)),
            );
          }

          final alerts = snapshot.data!.docs;

          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final data = alerts[index].data() as Map<String, dynamic>;

              Color alertColor = Colors.teal;
              if (data['type'] == 'critical') alertColor = Colors.red;
              if (data['type'] == 'warning') alertColor = Colors.orange;

              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: alertColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.notifications_active, color: alertColor, size: 20),
                ),
                title: Text(data['title'] ?? "Alert", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(data['message'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                trailing: Text(data['date'] ?? "", style: TextStyle(color: Colors.grey, fontSize: 10)),
                dense: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRealHealthTips() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tips').limit(5).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Padding(padding: EdgeInsets.all(16), child: Text("Error loading tips"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("No daily tips available.", style: TextStyle(color: Colors.grey)),
            );
          }

          final tips = snapshot.data!.docs;
          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            separatorBuilder: (context, index) => Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final data = tips[index].data() as Map<String, dynamic>;

              Color c = Colors.teal;
              String colName = (data['color'] ?? 'teal').toString().toLowerCase();
              if(colName == 'blue') c = Colors.blue;
              if(colName == 'purple') c = Colors.purple;
              if(colName == 'orange') c = Colors.orange;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: c.withOpacity(0.1),
                  child: Icon(Icons.lightbulb, color: c, size: 20),
                ),
                title: Text(data['title'] ?? "Tip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(data['subtitle'] ?? "", style: TextStyle(fontSize: 12)),
              );
            },
          );
        },
      ),
    );
  }
}