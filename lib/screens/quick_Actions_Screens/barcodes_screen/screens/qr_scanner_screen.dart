import 'dart:io';
// Ensure this path matches where you save the result file above
import 'package:drugsuremva/screens/quick_Actions_Screens/barcodes_screen/screens/qr_result_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isBusy = false;
  bool _isScanActive = true;
  String _statusText = "Initializing camera...";

  double _zoomLevel = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else {
      setState(() => _statusText = "Camera permission denied.");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _statusText = "No cameras found");
        return;
      }

      final camera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();

      // Attempt to set focus mode
      try {
        // FIX: Use FocusMode.auto (continuousVideo is deprecated/removed in newer versions)
        await _controller!.setFocusMode(FocusMode.auto);
      } catch (e) {
        // Ignore focus errors if device doesn't support it
      }

      try {
        _minZoom = await _controller!.getMinZoomLevel();
        _maxZoom = await _controller!.getMaxZoomLevel();
        _zoomLevel = _minZoom;
      } catch (e) {
        // Zoom info unavailable
      }

      if (mounted) {
        setState(() {
          _statusText = "Align QR code within the frame";
        });
        _controller!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      setState(() => _statusText = "Camera Error: $e");
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy || !_isScanActive || _controller == null) return;
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isBusy = false;
        return;
      }

      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final String? rawValue = barcode.rawValue;

        if (rawValue != null && rawValue.isNotEmpty) {
          _stopScanning();
          await _handleScanResult(barcode);
        }
      }
    } catch (e) {
      debugPrint("Scan Error: $e");
    } finally {
      _isBusy = false;
    }
  }

  void _stopScanning() {
    setState(() => _isScanActive = false);
  }

  void _resumeScanning() {
    setState(() {
      _isScanActive = true;
      _statusText = "Align QR code within the frame";
    });
  }

  Future<void> _handleScanResult(Barcode barcode) async {
    final String rawValue = barcode.rawValue ?? "";

    bool isMedicineData = _isLikelyMedicineData(rawValue);

    if (isMedicineData) {
      _navigateToResultScreen(rawValue);
    } else {
      final Uri? uri = Uri.tryParse(rawValue);
      bool isValidUrl = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

      if (isValidUrl) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) _resumeScanning();
        } else {
          _navigateToResultScreen(rawValue);
        }
      } else {
        _navigateToResultScreen(rawValue);
      }
    }
  }

  bool _isLikelyMedicineData(String raw) {
    if (raw.contains("(01)") || raw.contains("(10)") || raw.contains("(17)")) return true;
    if (RegExp(r'^01\d{14}').hasMatch(raw)) return true;
    return false;
  }

  void _navigateToResultScreen(String rawValue) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerResultScreen(rawValue: rawValue),
      ),
    ).then((_) {
      if (mounted) _resumeScanning();
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    if (Platform.isAndroid) {
      if (image.planes.length >= 1) { // NV21 typically has planes
        final allBytes = WriteBuffer();
        for (final plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }
    } else {
      // iOS BGRA8888
      if (image.planes.isNotEmpty) {
        return InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }
    }
    return null;
  }

  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void dispose() {
    _controller?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),

          // Overlay mask
          ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Zoom Slider
          Positioned(
            right: 10,
            top: 100,
            bottom: 100,
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: _zoomLevel,
                min: _minZoom,
                max: _maxZoom > 5.0 ? 5.0 : _maxZoom,
                activeColor: Colors.teal,
                inactiveColor: Colors.white30,
                onChanged: (value) {
                  setState(() => _zoomLevel = value);
                  _controller!.setZoomLevel(value);
                },
              ),
            ),
          ),

          // Status & Manual Rescan
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(
                    _statusText,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                if (!_isScanActive)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Scan Next"),
                    onPressed: _resumeScanning,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}