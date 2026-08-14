import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';
import 'main_screen.dart';
import 'sign_up_screen.dart';
import 'admin_dashboard_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await SocketService.login(username, password);

      if (response['statusCode'] == 200 || response['success'] == true) {
        final data = response['data'] is Map<String, dynamic> ? response['data'] : response;

        final int userId = data['userId'] ?? data['id'] ?? 0;
        final String savedUsername = data['username'] ?? username;
        final bool isAdmin = data['isAdmin'] == true || data['rank'] == 'ADMIN';

        await SessionManager().setUser(userId, savedUsername);
        SocketService.loggedInUsername = savedUsername;

        if (!mounted) return;

        if (isAdmin) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
          );
        }
      } else {
        _showError(response['message'] ?? "Login failed");
      }
    } catch (e) {
      _showError("Connection error. Please check server IP.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
                      border: Border.all(color: scheme.onSurface.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: scheme.primary, size: 55),
                        const SizedBox(height: 15),
                        Text(
                          "Welcome Back",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: scheme.onSurface),
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(usernameController, "Username", Icons.person, scheme),
                        const SizedBox(height: 18),
                        _buildTextField(passwordController, "Password", Icons.lock, scheme, obscure: true),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Log In", style: TextStyle(fontSize: 17)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSignUpLink(scheme),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, ColorScheme scheme, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: scheme.primary),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSignUpLink(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?", style: TextStyle(color: scheme.onSurfaceVariant)),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
          child: Text("Sign Up", style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
