import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MedicineScannerScreen extends StatefulWidget {
  const MedicineScannerScreen({super.key});

  @override
  State<MedicineScannerScreen> createState() => _MedicineScannerScreenState();
}

class _MedicineScannerScreenState extends State<MedicineScannerScreen> {
  CameraController? _cameraController;
  bool isBusy = false;
  String resultText = "Scan any Barcode / QR Code";

  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.first;

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    _cameraController!.startImageStream((image) {
      if (!isBusy) {
        isBusy = true;
        processImage(image);
      }
    });

    setState(() {});
  }

  Future<void> processImage(CameraImage image) async {
    try {
      // Combine planes into one Uint8List
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
      Size(image.width.toDouble(), image.height.toDouble());

      final camera = _cameraController!.description;

      final imageRotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation)
              ?? InputImageRotation.rotation0deg;

      final InputImageFormat inputFormat =
          InputImageFormatValue.fromRawValue(image.format.raw)
              ?? InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputFormat,
        bytesPerRow: image.planes.first.bytesPerRow, // REQUIRED
      );

      final inputImage =
      InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      final barcodes = await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final value = barcodes.first.rawValue ?? "";

        setState(() {
          resultText = value;
        });

        extractMedicineInfo(value);
      }
    } catch (e) {
      print("Error scanning: $e");
    }

    await Future.delayed(const Duration(milliseconds: 700));
    isBusy = false;
  }

  /// Extract dummy medicine info (you can replace with API/DB data)
  void extractMedicineInfo(String code) {
    if (code.contains("Dolo650")) {
      setState(() {
        resultText = """
Medicine Name: Dolo 650
Manufacturer: Micro Labs
Batch No: DL650A
Expiry: Oct 2026
Use: Fever, Body Pain
Ingredients: Paracetamol 650mg
""";
      });
    } else if (code.contains("Crocin")) {
      setState(() {
        resultText = """
Medicine Name: Crocin Advance
Manufacturer: GSK
Expiry: Jun 2027
Ingredients: Paracetamol 500mg
Use: Fever & Headache
""";
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Scanner"),
        backgroundColor: Colors.teal,
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          CameraPreview(_cameraController!),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.black87,
              child: Text(
                resultText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
