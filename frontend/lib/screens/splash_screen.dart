import 'dart:async';
import 'package:flutter/material.dart';
import 'entry_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const EntryScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        fit: StackFit.expand,

        children: [

          Image.asset(
            "assets/images/splash.jpg",
            fit: BoxFit.cover,
          ),

        ],

      ),

    );
  }
}