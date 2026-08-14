import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';
import 'main_screen.dart';
import 'log_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  final RegExp _usernameRegex = RegExp(r'^09\d{9}$|^[a-zA-Z0-9_.+-]+@gmail\.com$');
  final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

  @override
  void dispose() {
    usernameController.dispose();
    displayNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final username = usernameController.text.trim();
    final displayName = displayNameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    if (!_usernameRegex.hasMatch(username)) {
      _showError("Username must be a valid phone (09xxxxxxxx) or Gmail (@gmail.com)");
      return;
    }

    if (displayName.isEmpty) {
      _showError("Please enter your display name");
      return;
    }

    if (!_passwordRegex.hasMatch(password)) {
      _showError("Password must be 8+ chars and include uppercase, lowercase, and digits");
      return;
    }

    if (password.toLowerCase().contains(username.toLowerCase())) {
      _showError("Password MUST NOT contain your username");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await SocketService.signUp(username, password, displayName: displayName);

      if (response['success'] == true || response['statusCode'] == 200) {
        await SessionManager().setUser(
          response['userId'] ?? response['id'] ?? 0,
          username,
          displayNameValue: response['data']?['displayName'] ?? response['displayName'] ?? displayName,
        );

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      } else {
        _showError(response['message'] ?? "Sign up failed");
      }
    } catch (e) {
      _showError("Connection error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
            child: SingleChildScrollView(
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
                      border: Border.all(color: scheme.onSurface.withOpacity(0.22)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_alt_1, color: scheme.primary, size: 55),
                        const SizedBox(height: 15),
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: displayNameController,
                          style: TextStyle(color: scheme.onSurface),
                          decoration: _inputDecoration(scheme, "Display Name", Icons.badge_outlined),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: usernameController,
                          style: TextStyle(color: scheme.onSurface),
                          decoration: _inputDecoration(scheme, "Phone or Gmail", Icons.person_outline),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: scheme.onSurface),
                          decoration: _inputDecoration(scheme, "Password", Icons.lock),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          style: TextStyle(color: scheme.onSurface),
                          decoration: _inputDecoration(scheme, "Confirm Password", Icons.lock_outline),
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
                            onPressed: _isLoading ? null : _handleSignUp,
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text("Create Account", style: TextStyle(fontSize: 17)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildLoginLink(scheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme scheme, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant.withOpacity(0.8)),
      prefixIcon: Icon(icon, color: scheme.onSurfaceVariant),
      filled: true,
      fillColor: scheme.surface.withOpacity(0.78),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildLoginLink(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?", style: TextStyle(color: scheme.onSurface)),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          ),
          child: Text(
            "Log In",
            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}