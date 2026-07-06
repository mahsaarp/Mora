import 'package:flutter/material.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';

class CreateAlbumScreen extends StatefulWidget {
  final List<ExplorePhoto> availablePhotos;
  const CreateAlbumScreen({super.key, required this.availablePhotos});

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final Set<String> _selectedImageUrls = {};
  final TextEditingController _titleController = TextEditingController();

  Widget _buildImage(String urlOrPath, ThemeData theme) {
    final scheme = theme.colorScheme;
    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(width: double.infinity, height: double.infinity);
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: scheme.onSurfaceVariant),
        ),
      );
    }
    return Image.asset(
      urlOrPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_not_supported, color: scheme.onSurfaceVariant),
      ),
    );
  }

  void _submitAlbum() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an album title.")),
      );
      return;
    }
    if (_selectedImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one photo.")),
      );
      return;
    }
    final newAlbum = ExploreAlbum(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      photoCount: _selectedImageUrls.length,
      imageUrls: _selectedImageUrls.toList(),
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, newAlbum);
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
                hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.8)),
                prefixIcon: Icon(Icons.folder_open, color: scheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Photos:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: widget.availablePhotos.isEmpty
                  ? Center(
                child: Text(
                  "No photos available.",
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
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
                  final isSelected = _selectedImageUrls.contains(photo.imageUrl);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedImageUrls.remove(photo.imageUrl);
                        } else {
                          _selectedImageUrls.add(photo.imageUrl);
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
                              isSelected
                                  ? scheme.scrim.withOpacity(0.35)
                                  : Colors.transparent,
                              BlendMode.srcOver,
                            ),
                            child: _buildImage(photo.imageUrl, theme),
                          ),
                        ),
                        if (isSelected)
                          Center(
                            child: Icon(
                              Icons.check_circle,
                              color: scheme.primary,
                              size: 32,
                            ),
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
