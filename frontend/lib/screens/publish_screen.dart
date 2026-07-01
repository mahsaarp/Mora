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
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _publishPost() {

    final title = _titleController.text;
    final caption = _captionController.text;
    final tags = _tagsController.text;

    debugPrint("Title: $title");
    debugPrint("Caption: $caption");
    debugPrint("Tags: $tags");

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
          icon: const Icon(Icons.arrow_back,color: Colors.black),
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

              TextField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: "#nature #photography #travel",
                  prefixIcon: const Icon(Icons.tag),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
