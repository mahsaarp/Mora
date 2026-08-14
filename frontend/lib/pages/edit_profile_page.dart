import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;
  String? _currentAvatar;
  bool _avatarDeleted = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = SocketService.loggedInUsername ?? "";
    _displayNameController.text = SessionManager().displayName ?? "";
    _fetchCurrentProfile();
  }

  Future<void> _fetchCurrentProfile() async {
    try {
      final response = await SocketService.getUserProfile(SocketService.loggedInUsername ?? "");
      if (response['success'] == true || response['statusCode'] == 200) {
        setState(() {
          _currentAvatar = response['data']?['avatarRoute'] ?? response['data']?['avatar'];
          final data = response['data'] ?? {};
          final incomingDisplayName = (data['displayName'] ?? data['display_name'] ?? '').toString();
          if (incomingDisplayName.isNotEmpty) {
            _displayNameController.text = incomingDisplayName;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile for edit: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _avatarDeleted = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            if (_currentAvatar != null || _selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    _selectedImage = null;
                    _currentAvatar = null;
                    _avatarDeleted = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      String? avatarBase64;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        avatarBase64 = base64Encode(bytes);
      } else if (_avatarDeleted) {
        avatarBase64 = "";
      }

      final oldUsername = SocketService.loggedInUsername ?? "";
      final newUsername = _usernameController.text.trim();
      final newDisplayName = _displayNameController.text.trim();
      final newPassword = _passwordController.text.trim();

      final response = await SocketService.updateProfile(
        oldUsername: oldUsername,
        newUsername: newUsername.isNotEmpty && newUsername != oldUsername ? newUsername : null,
        newDisplayName: newDisplayName.isNotEmpty ? newDisplayName : null,
        newPassword: newPassword.isNotEmpty ? newPassword : null,
        avatarData: avatarBase64,
      );

      if (response['success'] == true || response['statusCode'] == 200) {
        if (newUsername.isNotEmpty && newUsername != oldUsername) {
          SocketService.loggedInUsername = newUsername;
          final userId = await SessionManager().userId;
          if (userId != null) {
            await SessionManager().setUser(userId, newUsername, displayNameValue: newDisplayName);
          }
        } else if (newDisplayName.isNotEmpty) {
          SessionManager().displayName = newDisplayName;
          final userId = await SessionManager().userId;
          if (userId != null) {
            await SessionManager().setUser(userId, SocketService.loggedInUsername ?? oldUsername, displayNameValue: newDisplayName);
          }
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Failed to update profile")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  ImageProvider _getAvatarProvider() {
    if (_selectedImage != null) return FileImage(_selectedImage!);
    if (_currentAvatar == null || _currentAvatar!.isEmpty) return const AssetImage("assets/images/profile.jpg");
    if (_currentAvatar!.startsWith('http')) return NetworkImage(_currentAvatar!);
    if (_currentAvatar!.startsWith('assets/')) return AssetImage(_currentAvatar!);
    if (_currentAvatar!.contains('uploads/')) return NetworkImage('${SocketService.baseUrl}/$_currentAvatar');

    try {
      String base64String = _currentAvatar!;
      if (_currentAvatar!.contains(',')) {
        base64String = _currentAvatar!.split(',')[1];
      }
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      return const AssetImage("assets/images/profile.jpg");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: _getAvatarProvider(),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primary,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: scheme.onPrimary,
                      ),
                      onPressed: _showImageSourceActionSheet,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: "Display Name",
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                hintText: "Leave blank to keep current",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
