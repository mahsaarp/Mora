import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';

class CreateAlbumScreen extends StatefulWidget {
  final List<ExplorePhoto> availablePhotos;
  const CreateAlbumScreen({super.key, required this.availablePhotos});

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final Set<String> _selectedPhotoIds = {};
  final TextEditingController _titleController = TextEditingController();
  bool _isSubmitting = false;

  Widget _buildImage(ExplorePhoto photo, ThemeData theme) {
    final scheme = theme.colorScheme;
    final urlOrPath = photo.imageUrl;

    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0);
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: scheme.onSurfaceVariant),
        ),
      );
    } else if (urlOrPath.startsWith('assets/')) {
      return Image.asset(
        urlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.image_not_supported, color: scheme.onSurfaceVariant),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: SocketService.downloadPhoto(int.tryParse(photo.id) ?? 0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0);
        }
        if (snapshot.hasData && (snapshot.data!['statusCode'] == 200 || snapshot.data!['success'] == true)) {
          final String? base64Data = snapshot.data!['data']?['fileData']?.toString();
          if (base64Data != null && base64Data.isNotEmpty) {
            return Image.memory(base64Decode(base64Data), fit: BoxFit.cover);
          }
        }
        return Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: scheme.onSurfaceVariant),
        );
      },
    );
  }

  void _submitAlbum() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an album title.")),
      );
      return;
    }
    if (_selectedPhotoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one photo.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final dynamic rawUserId = SessionManager().userId;
    final int? userId = int.tryParse(rawUserId.toString());

    if (userId == null || userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User session not found.")),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final List<int> selectedIds = _selectedPhotoIds.map((id) => int.tryParse(id) ?? 0).toList();

    final response = await SocketService.createAlbum(
      userId: userId,
      name: title,
      photoIds: selectedIds,
    );

    setState(() => _isSubmitting = false);

    if (response['statusCode'] == 200 || response['statusCode'] == 201 || response['success'] == true) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create album: ${response['message']}")),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Album"),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: Icon(Icons.check, color: scheme.onPrimary),
              onPressed: _submitAlbum,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: scheme.onSurface),
              decoration: InputDecoration(
                labelText: "Album Title",
                hintText: "Enter a name for your album",
                labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.folder_open, color: scheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Photos:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scheme.onSurface),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: widget.availablePhotos.isEmpty
                  ? Center(
                child: Text("No photos available.", style: TextStyle(color: scheme.onSurfaceVariant)),
              )
                  : GridView.builder(
                itemCount: widget.availablePhotos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final photo = widget.availablePhotos[index];
                  final isSelected = _selectedPhotoIds.contains(photo.id);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedPhotoIds.remove(photo.id);
                        } else {
                          _selectedPhotoIds.add(photo.id);
                        }
                      });
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              isSelected ? scheme.scrim.withOpacity(0.4) : Colors.transparent,
                              BlendMode.srcOver,
                            ),
                            child: _buildImage(photo, theme),
                          ),
                        ),
                        if (isSelected)
                          Center(
                            child: Icon(Icons.check_circle, color: scheme.primary, size: 32),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
