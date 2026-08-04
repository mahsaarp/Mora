import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';

class PublishScreen extends StatefulWidget {
  final File imageFile;

  const PublishScreen({super.key, required this.imageFile});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final title = _titleController.text.trim();
    final caption = _captionController.text.trim();

    if (title.isEmpty) {
      _showError("Photo Name is required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bytes = await widget.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // دریافت شناسه واقعی از SessionManager
      final int userId = SessionManager().userId ?? 0;

      final response = await SocketService.uploadPhoto(
        userId: userId,
        name: title,
        fileData: base64Image,
        caption: caption,
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
            TextButton(
              onPressed: _publishPost,
              child: const Text("Share", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(widget.imageFile, height: 250, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Photo Name *", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Caption", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }
}
