import 'package:flutter/material.dart';
import 'scanner_screen.dart';
import 'result_screen.dart';
import 'gemini_parser.dart';

class QrCodeScanning extends StatefulWidget {
  @override
  State<QrCodeScanning> createState() => _QrCodeScanningState();
}

class _QrCodeScanningState extends State<QrCodeScanning> {
  TextEditingController medName = TextEditingController();
  TextEditingController batchNo = TextEditingController();
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DrugSure - Verify Medicine")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: medName,
              decoration: InputDecoration(
                labelText: "Enter Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: batchNo,
              decoration: InputDecoration(
                labelText: "Enter Batch Number",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            /// Scan Button
            ElevatedButton(
              onPressed: () async {
                scannedCode = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MedicineScannerScreen()),
                );

                if (scannedCode != null) {
                  final decoded = await GeminiParser.decode(scannedCode!);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicineResultScreen(
                        resultData: decoded,
                      ),
                    ),
                  );
                }
              },
              child: Text("Scan QR / Barcode"),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
