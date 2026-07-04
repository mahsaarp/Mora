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
    final title = _titleController.text;
    final caption = _captionController.text;

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
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "New Post",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          TextButton(
            onPressed: _publishPost,
            child: const Text(
              "Share",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            ),
          )
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

              const Text(
                "Photo Name",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter photo name",
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Caption",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write something about this photo...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Tags",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
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

                              prefixText: "# ",
                              prefixStyle: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        if (_tagControllers.length > 1) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _removeTagField(index),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 4),

              TextButton.icon(
                onPressed: _addNewTagField,
                icon: const Icon(Icons.add, color: Colors.blueAccent),
                label: const Text(
                  "New tag",
                  style: TextStyle(
                    color: Colors.blueAccent,
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
