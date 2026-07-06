import 'dart:ui';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'log_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isEmail = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: scheme.scrim.withOpacity(0.20),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 12,
                  sigmaY: 12,
                ),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: scheme.surface.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: scheme.onSurface.withOpacity(0.22),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        color: scheme.primary,
                        size: 55,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join Mora and share your moments.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              value: true,
                              groupValue: isEmail,
                              activeColor: scheme.primary,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Email",
                                style: TextStyle(color: scheme.onSurface),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  isEmail = true;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              value: false,
                              groupValue: isEmail,
                              activeColor: scheme.primary,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Phone",
                                style: TextStyle(color: scheme.onSurface),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  isEmail = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: usernameController,
                        style: TextStyle(color: scheme.onSurface),
                        decoration: InputDecoration(
                          hintText: isEmail ? "Email" : "Phone Number",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                          prefixIcon: Icon(
                            isEmail ? Icons.email : Icons.phone,
                            color: scheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: scheme.surface.withOpacity(0.78),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: scheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: scheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(color: scheme.onSurface),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: scheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: scheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: scheme.surface.withOpacity(0.78),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: scheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: scheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        style: TextStyle(color: scheme.onSurface),
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(
                            color: scheme.onSurfaceVariant.withOpacity(0.8),
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: scheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: scheme.surface.withOpacity(0.78),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: scheme.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: scheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScreen(),
                              ),
                                  (route) => false,
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: scheme.onSurface),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
