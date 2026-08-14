import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/SocketService.dart';

class PublishScreen extends StatefulWidget {
  final File imageFile;

  const PublishScreen({super.key, required this.imageFile});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _userAlbums = [];
  final List<int> _selectedAlbumIds = [];

  @override
  void initState() {
    super.initState();
    _fetchUserAlbums();
  }

  Future<void> _fetchUserAlbums() async {
    try {
      final username = SocketService.loggedInUsername;
      if (username == null) return;

      final response = await SocketService.getUserProfile(username);
      if (response['statusCode'] == 200 || response['success'] == true) {
        final List<dynamic> albums = response['data']?['albums'] ?? [];
        setState(() {
          _userAlbums = albums.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching albums: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final title = _titleController.text.trim();
    final caption = _captionController.text.trim();
    final tagsText = _tagsController.text.trim();

    if (title.isEmpty) {
      _showError("Photo Name is required");
      return;
    }

    final List<String> tags = tagsText.isNotEmpty
        ? tagsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [];

    setState(() => _isLoading = true);

    try {
      final bytes = await widget.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final String username = SocketService.loggedInUsername ?? "";

      final response = await SocketService.uploadPhoto(
        username: username,
        name: title,
        fileData: base64Image,
        caption: caption,
        tags: tags,
        albumIds: _selectedAlbumIds,
        commentAllowed: true,
      );

      if (response['statusCode'] == 200 || response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post created successfully")),
        );
        Navigator.pop(context);
      } else {
        _showError(response['message'] ?? "Upload failed");
      }
    } catch (e) {
      _showError("Error uploading: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _publishPost,
                child: const Text("Share", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(widget.imageFile, height: 250, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Photo Name *",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Caption",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: "Tags (comma separated, e.g. nature, art)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_userAlbums.isNotEmpty) ...[
              const SizedBox(height: 25),
              const Text("Add to Albums:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _userAlbums.map((album) {
                  final albumId = album['id'] as int;
                  final isSelected = _selectedAlbumIds.contains(albumId);
                  return FilterChip(
                    label: Text(album['name'] ?? album['albumName'] ?? "Unnamed"),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAlbumIds.add(albumId);
                        } else {
                          _selectedAlbumIds.remove(albumId);
                        }
                      });
                    },
                    selectedColor: scheme.primaryContainer,
                    checkmarkColor: scheme.primary,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
