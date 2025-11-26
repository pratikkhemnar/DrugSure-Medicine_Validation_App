// // lib/screens/qr_home_screen.dart
//
// import 'package:flutter/material.dart';
// import 'qr_scanner_screen.dart';
// import 'qr_result_screen.dart';
// import '../services/qr_parser.dart';
// import '../models/medicine_info.dart';
//
// class QRHomeScreen extends StatelessWidget {
//   const QRHomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("DrugSure QR Scanner"),
//       ),
//       body: Center(
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.qr_code_scanner),
//           label: const Text("Scan Medicine QR"),
//           onPressed: () async {
//             final rawText = await Navigator.push<String>(
//               context,
//               MaterialPageRoute(builder: (_) => const QRScannerScreen()),
//             );
//
//             if (rawText != null && rawText.isNotEmpty) {
//               MedicineInfo info = parseMedicineQR(rawText);
//
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => QRResultScreen(info: info),
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
