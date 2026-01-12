import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Logger log = Logger();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final dio = Dio();
  String? _errorMessage;
  Map<String, dynamic>? result;

  // Animation
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(curve: Curves.easeOut, parent: _controller),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(curve: Curves.easeOutCubic, parent: _controller),
    );

    _controller.forward();
  }

  Future<void> onload(BuildContext context) async {
    if (await isMember() && context.mounted) {
      Navigator.pushReplacementNamed(context, '/member');
    }
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    const String serverURL = 'https://mobile.wattanapong.com/api/auth/login';

    try {
      final response = await dio.post(serverURL, data: {
        'email': email,
        'pass': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('name', data['member']['name']);
        prefs.setString('email', data['member']['email']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${data['member']['name']}")),
        );

        setState(() => result = data);
      } else {
        setState(() => _errorMessage = response.data['message']);
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data['message'] ?? e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text = "mobileinfo@cpe.ict.up.ac.th";
    _passwordController.text = "1234";

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923), // VALORANT dark blue-gray
      body: Row(
        children: [
          // 🔥 LEFT SIDE: Login Panel
          Expanded(
            flex: 4,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Container(
                  color: const Color(0xFFF2F2F2),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/5/5b/Riot_Games_logo.svg",
                        height: 60,
                      ),

                      const SizedBox(height: 40),

                      Row(
                        children: [
                          _tabButton("Sign-in", true),
                          const SizedBox(width: 10),
                          _tabButton("QR Code", false),
                        ],
                      ),

                      const SizedBox(height: 30),

                      _inputField("Email", _emailController),
                      const SizedBox(height: 15),
                      _inputField("Password", _passwordController, isPassword: true),
                      const SizedBox(height: 25),

                      _loginButton(),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 15),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],

                      const Spacer(),

                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/register'),
                              child: const Text("CREATE ACCOUNT",
                                  style: TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "v1.0.0",
                              style: TextStyle(color: Colors.black54),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔥 RIGHT SIDE: Agent Image
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/agent.png",
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 40,
                  right: 40,
                  child: Text(
                    "VALORANT LOGIN UI",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI BUILDERS ----------

  Widget _tabButton(String text, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE9E9E9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 1,
            )
          ],
        ),
        child: TextButton(
          onPressed: () async {
            await _login();
            if (mounted && result != null) {
              Navigator.pushReplacementNamed(context, '/member');
            }
          },
          child: const Text(
            "LOGIN",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> isMember() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('name') && prefs.containsKey('email');
  }
}
