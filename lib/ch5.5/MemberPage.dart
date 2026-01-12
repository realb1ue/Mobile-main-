import 'package:flutter/material.dart';
import 'package:mobile_software_development/ch5.4/ToDoList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  String? name = '';
  String? email = '';

  Future<void> readData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F1923),

      body: Column(
        children: [
          // ---------------- HEADER ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xff1C232E),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VALORANT Slash
                SizedBox(
                  height: 60,
                  child: CustomPaint(
                    painter: _ValorantSlashPainter(),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 42,
                        color: Color(0xff0F1923),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? "",
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email ?? "",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- TODO LIST CONTENT ----------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff1C232E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: ToDoListApp(),
                ),
              ),
            ),
          ),
        ],
      ),

      // ---------------- LOGOUT ----------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xffFF4655),
        onPressed: () async {
          await logout();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        label: const Text(
          "LOGOUT",
          style: TextStyle(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.logout),
      ),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('name');
    prefs.remove('email');
  }
}

// ------------------- SLASH EFFECT -------------------
class _ValorantSlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xffFF4655)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.7, size.height * 0.2),
      p,
    );

    canvas.drawLine(
      Offset(size.width * 0.3, size.height),
      Offset(size.width, size.height * 0.4),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
