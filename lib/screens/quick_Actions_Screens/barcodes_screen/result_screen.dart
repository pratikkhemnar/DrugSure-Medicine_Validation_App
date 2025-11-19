import 'package:flutter/material.dart';

class MedicineResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  MedicineResultScreen({required this.resultData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medicine Validation")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: resultData.containsKey("error")
            ? Center(child: Text("Error: ${resultData["error"]}"))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Medicine: ${resultData["name"]}",
                style: TextStyle(fontSize: 22)),
            SizedBox(height: 10),
            Text("Batch No: ${resultData["batch_no"]}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Expiry: ${resultData["expiry"]}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Manufacturer: ${resultData["manufacturer"]}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Verify Another"),
            )
          ],
        ),
      ),
    );
  }
}
