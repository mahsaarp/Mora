import 'package:flutter/material.dart';
import '../utils/explore_mock_data.dart';

class PhotoDetailScreen extends StatefulWidget {
  final ExplorePhoto photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  final TextEditingController _commentCtrl = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  late List<PhotoComment> _comments;
  late bool _allowComments;

  @override
  void initState() {
    super.initState();
    _allowComments = widget.photo.allowComments;

    _comments = [
      PhotoComment(
        id: 'c1',
        username: 'sara',
        userAvatar: "assets/images/user2.jpg",
        text: 'so pretty!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      PhotoComment(
        id: 'c2',
        username: 'ali',
        userAvatar: "assets/images/user1.jpg",
        text: 'beautiful!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        PhotoComment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          username: 'mahsa',
          userAvatar: "assets/images/profile.jpg",
          text: text,
          createdAt: DateTime.now(),
        ),
      );
      widget.photo.commentsCount += 1;
    });

    _commentCtrl.clear();
    _commentFocus.unfocus();
  }

  void _openEditSheet() async {
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditPhotoSheet(
        photo: widget.photo,
        currentAllowComments: _allowComments,
      ),
    );

    if (result == null) return;

    setState(() {
      widget.photo.name = result.name;
      widget.photo.caption = result.caption;
      widget.photo.tags = result.tags;
      _allowComments = result.allowComments;
      widget.photo.allowComments = result.allowComments;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.photo;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          if (p.isOwner)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit),
              onPressed: _openEditSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(p.imageUrl, fit: BoxFit.cover),
                if (p.isOwner)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _openEditSheet,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _PostHeaderInfo(
                    photo: p,
                    onTapComment: _allowComments ? () => _commentFocus.requestFocus() : null
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      p.caption,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                if (p.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: p.tags
                          .map((t) => Chip(
                        label: Text(t),
                        visualDensity: VisualDensity.compact,
                      ))
                          .toList(),
                    ),
                  ),
                const Divider(height: 16),
                Expanded(
                  child: _allowComments
                      ? _CommentsList(comments: _comments)
                      : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comments_disabled_outlined, color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text('Comments are turned off.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                if (_allowComments)
                  _CommentComposer(
                    controller: _commentCtrl,
                    focusNode: _commentFocus,
                    onSend: _addComment,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostHeaderInfo extends StatelessWidget {
  final ExplorePhoto photo;
  final VoidCallback? onTapComment;

  const _PostHeaderInfo({required this.photo, required this.onTapComment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(photo.userAvatar)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  photo.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.favorite, size: 18, color: Colors.red),
              const SizedBox(width: 6),
              Text('${photo.likes}'),
              const SizedBox(width: 16),
              InkWell(
                onTap: onTapComment,
                child: Row(
                  children: [
                    Icon(
                      onTapComment != null ? Icons.mode_comment_outlined : Icons.comments_disabled_outlined,
                      size: 18,
                      color: onTapComment != null ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${photo.commentsCount}',
                      style: TextStyle(color: onTapComment != null ? Colors.black : Colors.grey),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                photo.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentsList extends StatelessWidget {
  final List<PhotoComment> comments;

  const _CommentsList({required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(child: Text('There is no comments yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final c = comments[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 16, backgroundImage: AssetImage(c.userAvatar)),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${c.username}  ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: c.text),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xff6E8B5E)),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditResult {
  final String name;
  final String caption;
  final List<String> tags;
  final bool allowComments;

  _EditResult({
    required this.name,
    required this.caption,
    required this.tags,
    required this.allowComments
  });
}

class _EditPhotoSheet extends StatefulWidget {
  final ExplorePhoto photo;
  final bool currentAllowComments;

  const _EditPhotoSheet({required this.photo, required this.currentAllowComments});

  @override
  State<_EditPhotoSheet> createState() => _EditPhotoSheetState();
}

class _EditPhotoSheetState extends State<_EditPhotoSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _captionCtrl;
  late final TextEditingController _tagsCtrl;
  late bool _allowComments;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.photo.name);
    _captionCtrl = TextEditingController(text: widget.photo.caption);
    _tagsCtrl = TextEditingController(text: widget.photo.tags.join(' '));
    _allowComments = widget.currentAllowComments;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _captionCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(RegExp(r'[\s,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.startsWith('#') ? e : '#$e')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Wrap(
        runSpacing: 12,
        children: [
          const Text('Edit photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          TextField(
            controller: _captionCtrl,
            decoration: const InputDecoration(labelText: 'Caption'),
            maxLines: 3,
          ),
          TextField(
            controller: _tagsCtrl,
            decoration: const InputDecoration(labelText: 'Tags (space separated)'),
          ),
          SwitchListTile(
            title: const Text("Allow Comments"),
            subtitle: const Text("Users can post comments on this photo"),
            activeColor: const Color(0xff6E8B5E),
            value: _allowComments,
            onChanged: (val) {
              setState(() {
                _allowComments = val;
              });
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff6E8B5E)),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _EditResult(
                        name: _nameCtrl.text.trim(),
                        caption: _captionCtrl.text.trim(),
                        tags: _parseTags(_tagsCtrl.text),
                        allowComments: _allowComments,
                      ),
                    );
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class PhotoComment {
  final String id;
  final String username;
  final String userAvatar;
  final String text;
  final DateTime createdAt;

  PhotoComment({
    required this.id,
    required this.username,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
  });
}
