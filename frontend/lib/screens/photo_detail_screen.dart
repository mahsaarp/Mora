import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/explore_mock_data.dart';
import '../services/SocketService.dart';
import '../utils/shimmer_box.dart';
import '../model/comment.dart';

class PhotoDetailScreen extends StatefulWidget {
  final ExplorePhoto photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  final TextEditingController _commentCtrl = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  late List<Comment> _comments;
  late bool _allowComments;
  late bool _isLiked;
  late int _likes;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _allowComments = widget.photo.allowComments;
    _isLiked = widget.photo.isLiked;
    _likes = widget.photo.likes;
    _comments = List.from(widget.photo.comments);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final currentUsername = SocketService.loggedInUsername ?? "User";

    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
      widget.photo.likes = _likes;
      widget.photo.isLiked = _isLiked;
    });

    try {
      final photoIdInt = int.tryParse(widget.photo.id);
      if (photoIdInt != null && photoIdInt > 0) {
        await SocketService.likePhoto(currentUsername, photoIdInt);
      } else {
        debugPrint("Invalid photo ID for like: ${widget.photo.id}");
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final String username = SocketService.loggedInUsername ?? "User";
    final newComment = Comment(
      text: text,
      date: DateTime.now().toIso8601String(),
      username: username,
      avatarRoute: '',
    );

    setState(() {
      _comments = [newComment, ..._comments];
      widget.photo.comments = _comments;
      widget.photo.commentsCount = _comments.length;
    });

    _commentCtrl.clear();
    _commentFocus.unfocus();

    try {
      final photoIdInt = int.tryParse(widget.photo.id);
      if (photoIdInt != null && photoIdInt > 0) {
        await SocketService.addComment(username, photoIdInt, text);
      } else {
        debugPrint("Invalid photo ID for comment: ${widget.photo.id}");
      }
    } catch (e) {
      debugPrint("Error adding comment: $e");
    }
  }

  Future<String?> _prepareFileForSharing() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${widget.photo.name}_shared.jpg';

      if (widget.photo.imageUrl.startsWith('http')) {
        await Dio().download(widget.photo.imageUrl, path);
        return path;
      } else if (widget.photo.imageUrl.startsWith('assets/')) {
        return null;
      } else {
        final response = await SocketService.downloadPhoto(int.tryParse(widget.photo.id) ?? 0);
        if (response['statusCode'] == 200 || response['success'] == true) {
          final String? base64Data = response['data']?['fileData']?.toString();
          if (base64Data != null && base64Data.isNotEmpty) {
            final bytes = base64Decode(base64Data);
            final file = File(path);
            await file.writeAsBytes(bytes);
            return path;
          }
        }
      }
    } catch (e) {
      debugPrint("Error preparing file for sharing: $e");
    }
    return null;
  }

  Future<void> _downloadImage() async {
    setState(() => _isDownloading = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${widget.photo.name}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (widget.photo.imageUrl.startsWith('http')) {
        await Dio().download(widget.photo.imageUrl, path);
      } else if (widget.photo.imageUrl.startsWith('assets/')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Downloading assets is restricted.")),
        );
        setState(() => _isDownloading = false);
        return;
      } else {
        final response = await SocketService.downloadPhoto(int.tryParse(widget.photo.id) ?? 0);
        if (response['statusCode'] == 200 || response['success'] == true) {
          final String? base64Data = response['data']?['fileData']?.toString();
          if (base64Data != null && base64Data.isNotEmpty) {
            final bytes = base64Decode(base64Data);
            await File(path).writeAsBytes(bytes);
          } else {
            throw Exception("No image data received");
          }
        } else {
          throw Exception(response['message'] ?? "Failed to download");
        }
      }

      await Gal.putImage(path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image saved to gallery!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving image: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _shareImage() async {
    final path = await _prepareFileForSharing();
    if (path != null) {
      await Share.shareXFiles(
        [XFile(path)],
        text: '${widget.photo.name}\n${widget.photo.caption}',
      );
    } else {
      if (widget.photo.imageUrl.startsWith('http')) {
        await Share.share('${widget.photo.name}\n${widget.photo.imageUrl}');
      } else {
        await Share.share('Check out this photo: ${widget.photo.name} at Mora App!');
      }
    }
  }

  void _openEditSheet() async {
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditPhotoSheet(
        photo: widget.photo,
        currentAllowComments: _allowComments,
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      widget.photo.name = result.name;
      widget.photo.caption = result.caption;
      widget.photo.tags = result.tags;
      _allowComments = result.allowComments;
      widget.photo.allowComments = result.allowComments;
    });

    try {
      await SocketService.updatePhoto(
        photoId: int.tryParse(widget.photo.id) ?? 0,
        name: result.name,
        caption: result.caption,
        tags: result.tags,
        commentAllowed: result.allowComments,
      );
    } catch (e) {
      debugPrint("Error updating photo in database: $e");
    }
  }

  Widget _buildPhotoImage(String urlOrPath) {
    final scheme = Theme.of(context).colorScheme;

    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant, size: 40),
        ),
      );
    } else if (urlOrPath.startsWith('assets/')) {
      return Image.asset(
        urlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant, size: 40),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: SocketService.downloadPhoto(int.tryParse(widget.photo.id) ?? 0),
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
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant, size: 40),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.photo;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bool isMyPhoto = p.username == SocketService.loggedInUsername || p.isOwner;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadImage,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareImage,
          ),
          if (isMyPhoto)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _openEditSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _buildPhotoImage(p.imageUrl),
          ),
          Expanded(
            child: Column(
              children: [
                _PostHeaderInfo(
                  photo: p,
                  isLiked: _isLiked,
                  likes: _likes,
                  onToggleLike: _toggleLike,
                  onTapComment: _allowComments
                      ? () => _commentFocus.requestFocus()
                      : null,
                ),
                if (p.name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        p.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                if (p.caption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        p.caption,
                        style: TextStyle(color: scheme.onSurface),
                      ),
                    ),
                  ),
                if (p.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: p.tags
                            .map(
                              (t) => Chip(
                            label: Text(t.startsWith('#') ? t : '#$t'),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: scheme.primary.withValues(alpha: 0.12),
                            side: BorderSide(
                              color: scheme.primary.withValues(alpha: 0.25),
                            ),
                            labelStyle: TextStyle(color: scheme.primary, fontSize: 12),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),
                const Divider(height: 16),
                Expanded(
                  child: _allowComments
                      ? _CommentsList(comments: _comments)
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comments_disabled_outlined,
                          color: scheme.onSurfaceVariant,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comments are turned off.',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
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
  final bool isLiked;
  final int likes;
  final VoidCallback onToggleLike;

  const _PostHeaderInfo({
    required this.photo,
    required this.onTapComment,
    required this.isLiked,
    required this.likes,
    required this.onToggleLike,
  });

  ImageProvider _buildAvatarProvider(String avatarPath) {
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    }
    if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    }
    return NetworkImage('${SocketService.baseUrl}/$avatarPath');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: _buildAvatarProvider(photo.userAvatar),
              ),
              const SizedBox(width: 10),
              Text(
                photo.username,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? scheme.error : scheme.onSurface,
                ),
                onPressed: onToggleLike,
              ),
              const SizedBox(width: 6),
              Text(
                '$likes',
                style: TextStyle(color: scheme.onSurface),
              ),
              const SizedBox(width: 16),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  onTapComment != null
                      ? Icons.mode_comment_outlined
                      : Icons.comments_disabled_outlined,
                  color: scheme.onSurface,
                ),
                onPressed: onTapComment,
              ),
              const SizedBox(width: 6),
              Text(
                '${photo.commentsCount}',
                style: TextStyle(color: scheme.onSurface),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentsList extends StatelessWidget {
  final List<Comment> comments;

  const _CommentsList({required this.comments});

  ImageProvider _buildAvatarProvider(String? avatarPath) {
    final path = avatarPath ?? '';
    if (path.isEmpty) return const AssetImage('assets/images/default_avatar.png');
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return NetworkImage('${SocketService.baseUrl}/$path');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (comments.isEmpty) {
      return Center(
        child: Text(
          'No comments yet.',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final c = comments[index];
        final commenterName = (c.username ?? '').isNotEmpty ? c.username! : 'User';
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: _buildAvatarProvider(c.avatarRoute),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                    color: scheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: '$commenterName ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: scheme.primary),
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
    required this.allowComments,
  });
}

class _EditPhotoSheet extends StatefulWidget {
  final ExplorePhoto photo;
  final bool currentAllowComments;

  const _EditPhotoSheet({
    required this.photo,
    required this.currentAllowComments,
  });

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
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
          Text(
            'Edit photo',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          TextField(
            controller: _nameCtrl,
            style: TextStyle(color: scheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: scheme.onSurfaceVariant),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
          ),
          TextField(
            controller: _captionCtrl,
            style: TextStyle(color: scheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Caption',
              labelStyle: TextStyle(color: scheme.onSurfaceVariant),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
            maxLines: 3,
          ),
          TextField(
            controller: _tagsCtrl,
            style: TextStyle(color: scheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Tags (space separated)',
              labelStyle: TextStyle(color: scheme.onSurfaceVariant),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Allow Comments', style: TextStyle(color: scheme.onSurface)),
            subtitle: Text('Users can post comments on this photo', style: TextStyle(color: scheme.onSurfaceVariant)),
            activeTrackColor: scheme.primary,
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
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: scheme.outline),
                    foregroundColor: scheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Name cannot be empty")),
                      );
                      return;
                    }
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
                  child: const Text('Save'),
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