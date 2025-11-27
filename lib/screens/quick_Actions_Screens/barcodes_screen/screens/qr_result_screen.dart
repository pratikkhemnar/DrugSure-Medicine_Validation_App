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

class ResultScreen extends StatelessWidget {
  final String rawValue;

  ResultScreen({super.key, required this.rawValue});

  // 2. MOCK DATABASE (In a real app, you would fetch this from an API like GS1 or your own backend)
  final Map<String, ProductDetails> _productDatabase = {
    // GTIN for Limcee (From your image)
    "08904145936663": ProductDetails(
      genericName: "Vitamin C Chewable Tablets 500 mg",
      brandName: "Limcee®",
      manufacturer: "Abbott Healthcare Pvt. Ltd.",
      address: "Plot No. 26A, 27-30, Sector-8A, IIE, SIDCUL, Ranipur, Haridwar-249403(Uttarakhand), India.",
      licenseNumber: "21/UA/LL/SC/P-2020",
    ),
    // Example for Dolo-650 (For testing purposes)
    "08901234567890": ProductDetails(
      genericName: "Paracetamol Tablets IP 650 mg",
      brandName: "Dolo-650",
      manufacturer: "Micro Labs Limited",
      address: "92, Sipcot Industrial Complex, Hosur - 635 126, TN, India",
      licenseNumber: "TN/Drugs/1234",
    ),
  };

  @override
  Widget build(BuildContext context) {
    // Parse the scanned raw string to get codes
    final Map<String, String> parsedCodes = _parseMedicineData(rawValue);

    // Get the GTIN (Product ID) from the scan
    final String scannedGTIN = parsedCodes['GTIN'] ?? "";

    // Look up the product details in our database using the GTIN
    final ProductDetails? product = _productDatabase[scannedGTIN];

    // Determine if we found the product
    final bool isKnownProduct = product != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2C323E),
        toolbarHeight: 70,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                  "DrugSure",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Icon(Icons.menu, color: Colors.white),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Banner Logic: Show GENUINE if found in DB, else Show Warning
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                        color: isKnownProduct ? Colors.white : Colors.orange[50],
                        border: Border.all(
                            color: isKnownProduct ? Colors.green : Colors.orange,
                            width: 1.5
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          )
                        ]
                    ),
                    child: Text(
                      isKnownProduct ? "This Product is GENUINE" : "Product Not in Local Database",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isKnownProduct ? Colors.black87 : Colors.orange[900],
                        fontFamily: 'serif',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.black, thickness: 1.5),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fields scanned directly from the barcode
                        _buildRichText("Serial Number", parsedCodes['Serial'] ?? "Unknown"),
                        _buildRichText("Unique Product Identification Code", scannedGTIN.isNotEmpty ? scannedGTIN : "Unknown"),

                        // Fields fetched from Database (Dynamic)
                        _buildRichText(
                            "Proper and Generic Name of the drug",
                            isKnownProduct ? product!.genericName : "Unknown (GTIN Not Found)"
                        ),
                        _buildRichText(
                            "Brand Name",
                            isKnownProduct ? product!.brandName : "Unknown"
                        ),

                        _buildRichText(
                            "Name and address of the manufacturer",
                            isKnownProduct ? "${product!.manufacturer}. At: ${product!.address}" : "Unknown Manufacturer"
                        ),

                        // Fields scanned directly from the barcode
                        _buildRichText("Batch Number", parsedCodes['Batch'] ?? "Unknown"),

                        // Date of Mfg is usually NOT in the barcode, it's in the database.
                        // If we don't have DB info, we can't show it easily unless encoded in Batch (rare).
                        _buildRichText("Date of Manufacturing", isKnownProduct ? "Sep-2025" : "Unknown"),

                        _buildRichText("Date of Expiry", parsedCodes['Expiry'] ?? "Unknown"),

                        _buildRichText(
                            "Manufacturing license number",
                            isKnownProduct ? product!.licenseNumber : "Unknown"
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF2C323E),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("DrugSure", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                const Text(
                  "©2025 DrugSure, All Rights Reserved.",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRichText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.4,
            fontFamily: 'serif',
          ),
          children: [
            TextSpan(
              text: "$label : ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
                text: value,
                style: TextStyle(
                  // Highlight missing data in red slightly to indicate scan status
                    color: value.startsWith("Unknown") ? Colors.red.shade700 : Colors.black87
                )
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _parseMedicineData(String raw) {
    final Map<String, String> data = {};

    // Normalize raw string (remove brackets if HRI format)
    // Some scanners return "(01)123..." others return "01123..."
    String clean = raw.replaceAll('(', '').replaceAll(')', '');

    // 1. GTIN (01) - 14 digits fixed length
    // Look for (01) in raw OR 01 at start of clean string
    RegExp gtinReg = RegExp(r'(?:01)(\d{14})');
    var match = gtinReg.firstMatch(clean);
    if (match != null) {
      data['GTIN'] = match.group(1)!;
    }

    // 2. Expiry (17) - 6 digits (YYMMDD) fixed length
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
        data['Expiry'] = val; // Fallback if parse fails
      }
    }

    // 3. Batch (10) - Variable length up to 20 alpha-numeric
    // Note: In raw GS1 strings, variable fields are ended by a delimiter (FNC1).
    // Since we don't have the raw ASCII bytes here easily, we use a heuristic.
    // Usually Batch comes after GTIN or Expiry.
    RegExp batchReg = RegExp(r'(?:10)([a-zA-Z0-9]+)');
    match = batchReg.firstMatch(clean);
    if (match != null) {
      data['Batch'] = match.group(1)!;
    }

    // 4. Serial (21) - Variable length up to 20
    RegExp serialReg = RegExp(r'(?:21)([a-zA-Z0-9]+)');
    match = serialReg.firstMatch(clean);
    if (match != null) {
      data['Serial'] = match.group(1)!;
    }

    return data;
  }
}