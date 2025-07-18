import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://d42d-115-96-217-255.ngrok-free.app';

class MobileCameraDetectionScreen extends StatefulWidget {
  @override
  _MobileCameraDetectionScreenState createState() => _MobileCameraDetectionScreenState();
}

class _MobileCameraDetectionScreenState extends State<MobileCameraDetectionScreen> {
  CameraController? _controller;
  late FlutterTts _flutterTts;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 1; // Default to front camera
  String _prediction = "Waiting...";
  Timer? _timer;
  bool _isProcessing = false;
  String _lastSpoken = "";

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _prediction = "No camera found.");
        return;
      }

      // Set the front camera (or any camera available) as default
      _initializeCamera(_selectedCameraIndex);
    } catch (e) {
      setState(() => _prediction = "Camera error: $e");
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose(); // Dispose existing controller
    }

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      setState(() {});
      _startFrameCapture();
    } catch (e) {
      setState(() => _prediction = "Camera initialization error: $e");
    }
  }

  void _startFrameCapture() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _captureAndPredict());
  }

  Future<void> _captureAndPredict() async {
    if (_isProcessing || !_controller!.value.isInitialized) return;
    _isProcessing = true;

    try {
      final XFile file = await _controller!.takePicture();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody);
        final prediction = json['prediction'] ?? 'Unknown';

        if (prediction != _lastSpoken) {
          await _flutterTts.speak(prediction);
          _lastSpoken = prediction;
        }

        setState(() => _prediction = prediction);
      } else {
        setState(() => _prediction = "Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() => _prediction = "Error: $e");
    }

    _isProcessing = false;
  }

  void _flipCamera() {
    setState(() {
      // Toggle between front and back camera
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });
    _initializeCamera(_selectedCameraIndex); // Reinitialize with the new camera
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Sign Detection"),
        actions: [
          IconButton(
            icon: Icon(Icons.flip_camera_android),
            tooltip: 'Flip Camera',
            onPressed: _cameras.length > 1 ? _flipCamera : null,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            )
          else
            Center(child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            )),

          SizedBox(height: 16),
          Text(
            "Prediction:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _prediction,
              style: TextStyle(fontSize: 24, color: Colors.indigo),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
