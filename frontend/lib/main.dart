import 'package:flutter/material.dart';
import 'package:mora/screens/splash_screen.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mora',

          theme: ThemeData.light(),

          darkTheme: ThemeData.dark(),

          themeMode: currentMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}