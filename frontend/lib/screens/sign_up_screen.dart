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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary.withValues(alpha: 0.32),
              scheme.surface,
            ],
          ),
          image: const DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 360,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.18)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(Icons.person_add_alt_1_rounded, color: scheme.primary, size: 36),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: displayNameController,
                            style: TextStyle(color: scheme.onSurface),
                            decoration: _inputDecoration(scheme, "Display Name", Icons.badge_outlined),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: usernameController,
                            style: TextStyle(color: scheme.onSurface),
                            decoration: _inputDecoration(scheme, "Phone or Gmail", Icons.person_outline_rounded),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: TextStyle(color: scheme.onSurface),
                            decoration: _inputDecoration(scheme, "Password", Icons.lock_rounded),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            style: TextStyle(color: scheme.onSurface),
                            decoration: _inputDecoration(scheme, "Confirm Password", Icons.lock_outline_rounded),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: scheme.primary,
                                foregroundColor: scheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isLoading ? null : _handleSignUp,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text("Create Account", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 10),
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
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme scheme, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
      prefixIcon: Icon(icon, color: scheme.primary),
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 1.3),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildLoginLink(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?", style: TextStyle(color: scheme.onSurfaceVariant)),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          ),
          child: Text(
            "Log In",
            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}