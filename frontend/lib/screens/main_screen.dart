import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mora/pages/profile_page.dart';
import 'package:mora/pages/publish_page.dart';
import 'package:mora/pages/explore_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();

  final List<Widget> _screens = [
    const ExploreScreen(),
    const ProfilePage(),
  ];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PublishScreen(imageFile: File(image.path)),
        ),
      );
    }
  }

  void _showCreatePostBottomSheet() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: scheme.primary),
              title: Text("Camera", style: TextStyle(color: scheme.onSurface)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: scheme.primary),
              title: Text("Gallery", style: TextStyle(color: scheme.onSurface)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: _screens[_currentIndex],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: scheme.scrim.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.explore, "Explore", 0, scheme),
                  _buildNavItem(Icons.add_box_outlined, "Post", 1, scheme),
                  _buildNavItem(Icons.person, "Profile", 2, scheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, ColorScheme scheme) {
    final bool isSelected = (index == 0 && _currentIndex == 0) || (index == 2 && _currentIndex == 1);
    final activeColor = scheme.primary;
    final inactiveColor = scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () {
        if (index == 1) {
          _showCreatePostBottomSheet();
        } else if (index == 0) {
          setState(() => _currentIndex = 0);
        } else if (index == 2) {
          setState(() => _currentIndex = 1);
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}