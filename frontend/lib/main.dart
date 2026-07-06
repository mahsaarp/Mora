import 'package:flutter/material.dart';
import 'package:mora/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  void changeTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mora',

      theme: ThemeData.light(),

      darkTheme: ThemeData.dark(),

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      home: const SplashScreen(),
    );
  }
}