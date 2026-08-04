import 'dart:io';
import 'package:flutter/material.dart';

class PublishScreen extends StatefulWidget {
  final File imageFile;

  const PublishScreen({super.key, required this.imageFile});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  final List<TextEditingController> _tagControllers = [];

  @override
  void initState() {
    super.initState();
    _tagControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    for (var controller in _tagControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewTagField() {
    setState(() {
      _tagControllers.add(TextEditingController());
    });
  }

  void _removeTagField(int index) {
    if (_tagControllers.length > 1) {
      setState(() {
        _tagControllers[index].dispose();
        _tagControllers.removeAt(index);
      });
    }
  }

  void _publishPost() {
    final title = _titleController.text.trim();
    final caption = _captionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photo Name is required"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final tagsList = _tagControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .map((text) => '#$text')
        .toList();

    debugPrint("Title: $title");
    debugPrint("Caption: $caption");
    debugPrint("Tags List: $tagsList");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post created successfully"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("New Post"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _publishPost,
            child: Text(
              "Share",
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    widget.imageFile,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Photo Name *",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter photo name",
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.image_outlined,
                    color: scheme.primary,
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withOpacity(0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Caption",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write something about this photo...",
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withOpacity(0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Tags",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tagControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagControllers[index],
                            decoration: InputDecoration(
                              hintText: "nature",
                              hintStyle:
                              TextStyle(color: scheme.onSurfaceVariant),
                              prefixText: "# ",
                              prefixStyle: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor:
                              scheme.surfaceContainerHighest.withOpacity(0.35),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (_tagControllers.length > 1) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: scheme.error,
                            ),
                            onPressed: () => _removeTagField(index),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _addNewTagField,
                icon: Icon(Icons.add, color: scheme.primary),
                label: Text(
                  "New tag",
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
