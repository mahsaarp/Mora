import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../services/SocketService.dart';
import 'entry_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 1400));

    final isLoggedIn = await SessionManager().initSession();

    await _controller.reverse();

    if (!mounted) return;

    Widget nextScreen;
    if (isLoggedIn) {
      SocketService.loggedInUsername = SessionManager().username;
      nextScreen = const MainScreen();
    } else {
      nextScreen = const EntryScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: nextScreen,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/splash.png",
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}