import 'dart:ui';
import 'package:flutter/material.dart';
import 'log_in_screen.dart';
import 'sign_up_screen.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/background.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: scheme.scrim.withOpacity(0.20)),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: scheme.surface.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: scheme.onSurface.withOpacity(0.4)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: scheme.primary, size: 55),
                      const SizedBox(height: 15),
                      Text(
                        "Mora",
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Capture. Share. Inspire.",
                        style: TextStyle(
                          fontSize: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                          ),
                          child: const Text("Log In", style: TextStyle(fontSize: 17)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: scheme.primary, width: 2),
                            foregroundColor: scheme.primary,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          ),
                          child: const Text("Sign Up", style: TextStyle(fontSize: 17)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
