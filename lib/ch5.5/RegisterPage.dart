import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

Logger log = Logger();

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final dio = Dio();
  Map<String, dynamic>? result;

  String? _errorMessage;

  Future<void> register() async {
    final messenger = ScaffoldMessenger.of(context);

    const String serverURL =
        'https://mobile.wattanapong.com/api/auth/register';

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await dio.post(
        serverURL,
        data: {
          'email': _emailController.text,
          'pass': _passwordController.text,
          'name': _nameController.text,
        },
      );

      if (response.statusCode == 201 && context.mounted) {
        setState(() => result = response.data);

        messenger.showSnackBar(
          const SnackBar(
            content: Text('Register successful! Go back to Login Page'),
          ),
        );
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data["message"] ??
            'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0F1923); // Valorant dark navy
    const accentRed = Color(0xFFFF4655); // Valorant red
    const textGray = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgDark,

      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "REGISTER",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            height: 4,
            width: 150,
            decoration: const BoxDecoration(
              color: accentRed,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --------- EMAIL ----------
            _buildValorantField(
              controller: _emailController,
              label: "EMAIL",
            ),

            const SizedBox(height: 18),

            // --------- PASSWORD ----------
            _buildValorantField(
              controller: _passwordController,
              label: "PASSWORD",
              obscure: true,
            ),

            const SizedBox(height: 18),

            // --------- NAME ----------
            _buildValorantField(
              controller: _nameController,
              label: "NAME",
            ),

            const SizedBox(height: 30),

            // --------- REGISTER BUTTON ----------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: accentRed,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
                child: const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --------- LOGIN BUTTON ----------
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "BACK TO LOGIN",
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValorantField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
