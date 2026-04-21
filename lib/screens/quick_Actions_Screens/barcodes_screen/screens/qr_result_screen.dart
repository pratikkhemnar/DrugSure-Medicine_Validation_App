import 'package:flutter/material.dart';

// 1. Define a Model for Product Details
class ProductDetails {
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String address;
  final String licenseNumber;

  ProductDetails({
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.address,
    required this.licenseNumber,
  });
}

class ScannerResultScreen extends StatelessWidget {
  final String rawValue;

  ScannerResultScreen({Key? key, required this.rawValue}) : super(key: key);

  // 2. MOCK DATABASE
  final Map<String, ProductDetails> _productDatabase = {
    // GTIN for Limcee
    "08904145936663": ProductDetails(
      genericName: "Vitamin C Chewable Tablets 500 mg",
      brandName: "Limcee®",
      manufacturer: "Abbott Healthcare Pvt. Ltd.",
      address: "Plot No. 26A, 27-30, Sector-8A, IIE, SIDCUL, Ranipur, Haridwar",
      licenseNumber: "21/UA/LL/SC/P-2020",
    ),
    // Example for Dolo-650
    "08901234567890": ProductDetails(
      genericName: "Paracetamol Tablets IP 650 mg",
      brandName: "Dolo-650",
      manufacturer: "Micro Labs Limited",
      address: "92, Sipcot Industrial Complex, Hosur, TN",
      licenseNumber: "TN/Drugs/1234",
    ),
  };

  @override
  Widget build(BuildContext context) {
    // --- LOGIC SECTION ---

    // Parse the scanned raw string to get codes
    final Map<String, String> parsedCodes = _parseMedicineData(rawValue);

    // Get the GTIN (Product ID) from the scan
    final String scannedGTIN = parsedCodes['GTIN'] ?? "";

    // Look up the product details in our database using the GTIN
    final ProductDetails? product = _productDatabase[scannedGTIN];
    final bool isKnownProduct = product != null;

    // --- DESIGN CONFIGURATION ---
    Color primaryColor;
    Color secondaryColor;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;
    IconData overlayIcon;

    if (isKnownProduct) {
      // GENUINE STYLE
      primaryColor = Colors.teal;
      secondaryColor = Colors.greenAccent.shade700;
      statusIcon = Icons.verified_user_rounded;
      overlayIcon = Icons.check_circle_outline;
      statusTitle = "GENUINE";
      statusSubtitle = "Official Product\nVerified in Database";
    } else {
      // UNKNOWN / CAUTION STYLE
      primaryColor = Colors.orange.shade800;
      secondaryColor = Colors.orange.shade600;
      statusIcon = Icons.help_outline_rounded;
      overlayIcon = Icons.travel_explore; // Searching icon
      statusTitle = "SAFE";
      statusSubtitle = "Product not found in\nlocal database";
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "DrugSure",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Gradient Background
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                ),

                // 2. Giant Watermark Icon
                Positioned(
                  right: -30,
                  top: 60,
                  child: Icon(
                    overlayIcon,
                    size: 200,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),

                // 3. Central Status Content
                Positioned(
                  top: 100,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          statusIcon,
                          size: 60,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        statusSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- DETAILS SECTION ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                children: [
                  // Info Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(Icons.qr_code_2, color: Colors.grey[400]),
                              SizedBox(width: 10),
                              Text(
                                "Scanned Details",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[100]),

                        // Details List
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Database Fields (if found)
                              _buildDetailRow("Brand Name", isKnownProduct ? product!.brandName : "Unknown", isHighlight: true),
                              _buildDetailRow("Generic Name", isKnownProduct ? product!.genericName : "N/A"),
                              _buildDetailRow("Manufacturer", isKnownProduct ? product!.manufacturer : "Unknown"),

                              // Scanned Fields (from Barcode)
                              _buildDetailRow("Batch Number", parsedCodes['Batch'], isHighlight: true),
                              _buildDetailRow("Serial Number", parsedCodes['Serial']),
                              _buildDetailRow("GTIN / UPIC", scannedGTIN.isNotEmpty ? scannedGTIN : "N/A"),
                              _buildDetailRow("Exp. Date", parsedCodes['Expiry'], isExpiry: true),

                              // License (Database)
                              _buildDetailRow("License No.", isKnownProduct ? product!.licenseNumber : "N/A"),
                            ],
                          ),
                        ),

                        // Bottom Watermark
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified, size: 16, color: primaryColor),
                              SizedBox(width: 6),
                              Text(
                                isKnownProduct ? "Verified by DrugSure Database" : "Not found in Local Database",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                      label: Text(
                        "SCAN ANOTHER",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 5,
                        shadowColor: primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildDetailRow(String label, String? value, {bool isHighlight = false, bool isExpiry = false}) {
    // Clean up value
    String displayValue = (value == null || value.isEmpty) ? "N/A" : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: TextStyle(
                color: isExpiry ? Colors.red[700] : Colors.grey[900],
                fontSize: 15,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _parseMedicineData(String raw) {
    final Map<String, String> data = {};

    // Normalize raw string
    String clean = raw.replaceAll('(', '').replaceAll(')', '');

    // 1. GTIN (01)
    RegExp gtinReg = RegExp(r'(?:01)(\d{14})');
    var match = gtinReg.firstMatch(clean);
    if (match != null) {
      data['GTIN'] = match.group(1)!;
    }

    // 2. Expiry (17)
    RegExp expiryReg = RegExp(r'(?:17)(\d{6})');
    match = expiryReg.firstMatch(clean);
    if (match != null) {
      String val = match.group(1)!;
      try {
        String year = "20${val.substring(0, 2)}";
        String monthNum = val.substring(2, 4);
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        String month = months[int.parse(monthNum) - 1];
        data['Expiry'] = "$month-$year";
      } catch (e) {
        data['Expiry'] = val;
      }
    }

    // 3. Batch (10)
    RegExp batchReg = RegExp(r'(?:10)([a-zA-Z0-9]+)');
    match = batchReg.firstMatch(clean);
    if (match != null) {
      data['Batch'] = match.group(1)!;
    }

    // 4. Serial (21)
    RegExp serialReg = RegExp(r'(?:21)([a-zA-Z0-9]+)');
    match = serialReg.firstMatch(clean);
    if (match != null) {
      data['Serial'] = match.group(1)!;
    }

    return data;
  }
}