import 'package:flutter/material.dart';

class MedicineResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const MedicineResultScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Get status from data
    final String statusRaw = data['result'] ?? 'Unknown';
    final String status = statusRaw.trim();

    // 2. Determine Styling based on status
    Color primaryColor;
    Color secondaryColor; // For gradient
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;
    IconData overlayIcon;

    switch (status.toLowerCase()) {
      case 'genuine':
      case 'valid':
      case 'safe':
        primaryColor = Colors.teal;
        secondaryColor = Colors.greenAccent.shade700;
        statusIcon = Icons.verified_user_rounded;
        overlayIcon = Icons.check_circle_outline;
        statusTitle = "GENUINE";
        statusSubtitle = "Official Product\nVerified Safe";
        break;

      case 'banned':
        primaryColor = Colors.red.shade800;
        secondaryColor = Colors.red.shade600;
        statusIcon = Icons.block_flipped;
        overlayIcon = Icons.dangerous_outlined;
        statusTitle = "BANNED";
        statusSubtitle = "Regulatory Alert\nDo Not Use";
        break;

      case 'caution':
      case 'warning':
        primaryColor = Colors.orange.shade800;
        secondaryColor = Colors.orange.shade600;
        statusIcon = Icons.warning_amber_rounded;
        overlayIcon = Icons.priority_high_rounded;
        statusTitle = "CAUTION";
        statusSubtitle = "Potential Issue\nVerify Details";
        break;

      case 'fake':
      case 'counterfeit':
        primaryColor = Colors.red.shade900;
        secondaryColor = Colors.deepOrange.shade900;
        statusIcon = Icons.error_outline_rounded;
        overlayIcon = Icons.cancel_outlined;
        statusTitle = "FAKE";
        statusSubtitle = "Counterfeit Alert\nReport Immediately";
        break;

      default:
        primaryColor = Colors.grey.shade700;
        secondaryColor = Colors.grey.shade500;
        statusIcon = Icons.help_outline_rounded;
        overlayIcon = Icons.help_outline;
        statusTitle = "UNKNOWN";
        statusSubtitle = "Status Unverified\nCheck Manually";
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true, // Makes the header go behind the status bar
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

                // 2. Giant Watermark Icon (Subtle background)
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
                              Icon(Icons.info_outline, color: Colors.grey[400]),
                              SizedBox(width: 10),
                              Text(
                                "Medicine Details",
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
                              _buildDetailRow("Brand Name", data['brandName'], isHighlight: true),
                              _buildDetailRow("Generic Name", data['genericName']),
                              _buildDetailRow("Manufacturer", data['manufacturer']),
                              _buildDetailRow("Batch Number", data['batchNumber']),
                              _buildDetailRow("Serial Number", data['serialNumber']),
                              _buildDetailRow("UPIC Code", data['upic']),
                              _buildDetailRow("Mfg. Date", data['manufactureDate']),
                              _buildDetailRow("Exp. Date", data['expiryDate'], isExpiry: true),
                              _buildDetailRow("License No.", data['licenseNo']),
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
                              Icon(Icons.verified, size: 16, color: Colors.teal),
                              SizedBox(width: 6),
                              Text(
                                "Verified by DrugSure Database",
                                style: TextStyle(
                                  color: Colors.teal[700],
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
                      icon: Icon(Icons.search, color: Colors.white),
                      label: Text(
                        "SEARCH ANOTHER",
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

  Widget _buildDetailRow(String label, String? value, {bool isHighlight = false, bool isExpiry = false}) {
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
              value ?? "N/A",
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
}