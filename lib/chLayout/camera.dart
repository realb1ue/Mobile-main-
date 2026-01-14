import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math;


/// ================== MODEL ==================
class Detection {
  final double x1, y1, x2, y2;
  final double confidence;
  final int cls;

  Detection.fromJson(Map<String, dynamic> json)
      : x1 = (json['x1'] as num).toDouble(),
        y1 = (json['y1'] as num).toDouble(),
        x2 = (json['x2'] as num).toDouble(),
        y2 = (json['y2'] as num).toDouble(),
        confidence = (json['confidence'] as num).toDouble(),
        cls = json['class'];
}

/// ================== MAIN ==================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectImageScreen(),
    );
  }
}

/// ================== SELECT IMAGE SCREEN ==================
class SelectImageScreen extends StatefulWidget {
  const SelectImageScreen({super.key});

  @override
  State<SelectImageScreen> createState() => _SelectImageScreenState();
}

class _SelectImageScreenState extends State<SelectImageScreen> {
  bool isLoading = false;

  /// 🔥 ส่งรูปไป YOLO
  Future<List<Detection>> sendToYolo(
    Uint8List bytes,
    String filename,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/detect'), // 🔧 เปลี่ยน IP ถ้าใช้เครื่องจริง
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final jsonData = jsonDecode(body);

    return (jsonData['detections'] as List)
        .map((e) => Detection.fromJson(e))
        .toList();
  }

  /// 📁 เลือกรูปจากเครื่อง
  Future<void> pickImage() async {
    try {
      setState(() => isLoading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // ⭐ สำคัญมาก (Web ต้องใช้)
      );

      if (result == null) return;

      final bytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      final detections = await sendToYolo(bytes, fileName);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DisplayPictureScreen(
            imageBytes: bytes,
            detections: detections,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Pick image error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/number_egg_logo.png',
                    width: 250,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text(
                      "เลือกรูปจากเครื่อง",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// ================== DISPLAY RESULT ==================
class DisplayPictureScreen extends StatelessWidget {
  final Uint8List imageBytes;
  final List<Detection> detections;

  const DisplayPictureScreen({
    super.key,
    required this.imageBytes,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
                CustomPaint(
                  painter: YoloPainter(
                    detections,
                    const Size(640, 640), // ปรับตาม input YOLO
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "พบวัตถุทั้งหมด: ${detections.length}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================== YOLO PAINTER ==================
class YoloPainter extends CustomPainter {
  final List<Detection> detections;
  final Size imageSize; // เช่น 640x640

  YoloPainter(this.detections, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    // scale ที่แท้จริง
    final scale = math.min(
      size.width / imageSize.width,
      size.height / imageSize.height,
    );

    // คำนวณขอบดำ (letterbox)
    final dx = (size.width - imageSize.width * scale) / 2;
    final dy = (size.height - imageSize.height * scale) / 2;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final d in detections) {
      final rect = Rect.fromLTRB(
        d.x1 * scale + dx,
        d.y1 * scale + dy,
        d.x2 * scale + dx,
        d.y2 * scale + dy,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
