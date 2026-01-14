import 'package:flutter/material.dart';

import 'chLayout/MainPage.dart';
import 'chLayout/Login.dart';
import 'chLayout/Register.dart';
import 'chLayout/camera.dart';
import 'chLayout/HomePage.dart';
import 'chLayout/ProfilePage.dart';
//import 'chLayout/MemberPage.dart';

void main() {
  runApp(const LinkPage());
}

class LinkPage extends StatelessWidget {
  const LinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/camera': (context) => const SelectImageScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/member': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
