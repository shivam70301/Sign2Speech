import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sign2speech/job_opportunities.dart';
import 'package:sign2speech/courses.dart';
import 'mobiledetection.dart';

const String baseUrl = 'https://d42d-115-96-217-255.ngrok-free.app';

void main() {
  runApp(Sign2SpeechApp());
}

class Sign2SpeechApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign2Speech',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _detectedSign = '';
  bool _isDetecting = false;
  final FlutterTts flutterTts = FlutterTts();
  final String flaskApiUrl = '$baseUrl/predict';

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  Future<void> _handleImage(XFile image) async {
    setState(() {
      _isDetecting = true;
      _detectedSign = 'Detecting...';
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(flaskApiUrl));
      if (kIsWeb) {
        var bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(respStr);
        String prediction = decoded['prediction'] ?? 'No prediction found';
        setState(() {
          _detectedSign = prediction;
        });
        await _speak(prediction);
      } else {
        setState(() {
          _detectedSign = 'Error ${response.statusCode}: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _detectedSign = 'Error: $e';
      });
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _handleImage(image);
  }

  Future<void> _captureFromCamera() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MobileCameraDetectionScreen()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign2Speech')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.accessible_forward, size: 80, color: Colors.indigo.withOpacity(0.5)),
                      SizedBox(height: 20),
                      Text(
                        _detectedSign.isEmpty ? 'Ready to detect' : _detectedSign,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -3))],
            ),
            child: Column(
              children: [
                Text('Detected Sign', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _detectedSign.isNotEmpty ? _detectedSign : 'No sign detected yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: _detectedSign.isNotEmpty ? Colors.indigo : Colors.grey),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureButton(icon: Icons.work, label: 'Jobs', onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => JobOpportunitiesPage()));
                    }),
                    _buildFeatureButton(icon: Icons.school, label: 'Courses', onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CoursesPage()));
                    }),
                    _buildFeatureButton(icon: Icons.history, label: 'History', onTap: () {
                      // TODO: Implement History Page
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isDetecting
          ? FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.hourglass_top, size: 32),
        tooltip: 'Detecting...',
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'gallery',
            onPressed: _pickFromGallery,
            icon: Icon(Icons.photo),
            label: Text("Upload"),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'camera',
            onPressed: _captureFromCamera,
            icon: Icon(Icons.videocam),
            label: Text("Live Camera"),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Colors.indigo),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
