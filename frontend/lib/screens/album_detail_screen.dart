import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';
import 'photo_detail_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final ExploreAlbum album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  List<ExplorePhoto> _albumPhotos = [];
  bool _isLoading = true;
  bool _isSelectMode = false;
  final Set<String> _selectedPhotoIds = {};
  String _currentSort = 'Newest';

  bool get _isOwner {
    final currentUserId = SessionManager().userId?.toString();
    return widget.album.ownerId == currentUserId && currentUserId != null;
  }

  @override
  void initState() {
    super.initState();
    _fetchAlbumDetails();
  }

  Future<void> _fetchAlbumDetails() async {
    try {
      final response = await SocketService.getAlbumDetails(int.parse(widget.album.id));
      if (response['success'] == true || response['statusCode'] == 200) {
        final List photoData = response['data']['photos'] ?? [];
        if (mounted) {
          setState(() {
            _albumPhotos = photoData.map((json) => ExplorePhoto.fromJson(json)).toList();
            _sortPhotos(_currentSort);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching album details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sortPhotos(String criteria) {
    setState(() {
      _currentSort = criteria;
      if (criteria == 'Most Liked') {
        _albumPhotos.sort((a, b) => b.likes.compareTo(a.likes));
      } else if (criteria == 'Newest') {
        _albumPhotos.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      } else if (criteria == 'Oldest') {
        _albumPhotos.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
      } else if (criteria == 'Name') {
        _albumPhotos.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    });
  }

  void _toggleSelectPhoto(String photoId) {
    if (!_isOwner || photoId.isEmpty) return;
    setState(() {
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
        if (_selectedPhotoIds.isEmpty) _isSelectMode = false;
      } else {
        _selectedPhotoIds.add(photoId);
        _isSelectMode = true;
      }
    });
  }

  Future<void> _removeSelectedFromAlbum() async {
    if (!_isOwner) return;
    final albumId = int.tryParse(widget.album.id) ?? 0;
    for (String id in _selectedPhotoIds) {
      await SocketService.removePhotoFromAlbum(albumId: albumId, photoId: int.tryParse(id) ?? 0);
    }
    _clearSelection();
    _fetchAlbumDetails();
  }

  Future<void> _deleteSelectedPermanently() async {
    if (!_isOwner) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permanent Delete"),
        content: Text("Are you sure you want to permanently delete ${_selectedPhotoIds.length} photos?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    for (String id in _selectedPhotoIds) {
      await SocketService.deletePhoto(int.tryParse(id) ?? 0);
    }
    _clearSelection();
    _fetchAlbumDetails();
  }

  Future<void> _moveToAnotherAlbum() async {
    if (!_isOwner) return;
    final username = SocketService.loggedInUsername ?? "";
    final response = await SocketService.getUserProfile(username);
    if (!mounted) return;
    List<ExploreAlbum> allAlbums = [];
    if (response['statusCode'] == 200 || response['success'] == true) {
      allAlbums = (response['data']['albums'] as List? ?? [])
          .map((json) => ExploreAlbum.fromJson(json))
          .where((a) => a.id != widget.album.id)
          .toList();
    }
    if (allAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No other albums available.")));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allAlbums.length,
        itemBuilder: (ctx, idx) {
          final target = allAlbums[idx];
          return ListTile(
            leading: const Icon(Icons.photo_album),
            title: Text(target.title),
            onTap: () async {
              Navigator.pop(ctx);
              final currentId = int.tryParse(widget.album.id) ?? 0;
              final targetId = int.tryParse(target.id) ?? 0;
              for (String pid in _selectedPhotoIds) {
                final idInt = int.tryParse(pid) ?? 0;
                await SocketService.addPhotoToAlbum(albumId: targetId, photoId: idInt);
                await SocketService.removePhotoFromAlbum(albumId: currentId, photoId: idInt);
              }
              _clearSelection();
              _fetchAlbumDetails();
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteAlbum() async {
    if (!_isOwner) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Album"),
        content: const Text("Are you sure you want to delete this album? Photos will not be deleted."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final res = await SocketService.deleteAlbum(int.parse(widget.album.id));
    if (mounted) {
      if (res['success'] == true || res['statusCode'] == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Error deleting album")));
      }
    }
  }

  void _clearSelection() {
    setState(() { _isSelectMode = false; _selectedPhotoIds.clear(); });
  }

  Widget _buildImage(ExplorePhoto photo, ThemeData theme) {
    if (photo.imageUrl.startsWith('assets/')) return Image.asset(photo.imageUrl, fit: BoxFit.cover);
    return FutureBuilder<Map<String, dynamic>>(
      future: SocketService.downloadPhoto(int.tryParse(photo.id) ?? 0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0);
        if (snapshot.hasData && (snapshot.data!['success'] == true || snapshot.data!['statusCode'] == 200)) {
          final base64 = snapshot.data!['data']?['fileData'] ?? '';
          if (base64.isNotEmpty) return Image.memory(base64Decode(base64), fit: BoxFit.cover);
        }
        return Container(color: theme.colorScheme.surfaceContainerHighest, child: const Icon(Icons.broken_image));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: _isSelectMode
          ? AppBar(
        backgroundColor: scheme.primaryContainer,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _clearSelection),
        title: Text("${_selectedPhotoIds.length} Selected"),
        actions: [
          if (_isOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'remove') _removeSelectedFromAlbum();
                else if (val == 'delete') _deleteSelectedPermanently();
                else if (val == 'move') _moveToAnotherAlbum();
                else _clearSelection();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'remove', child: Text("Remove from album")),
                const PopupMenuItem(value: 'delete', child: Text("Permanent Delete", style: TextStyle(color: Colors.red))),
                const PopupMenuItem(value: 'move', child: Text("Move to another album")),
                const PopupMenuItem(value: 'cancel', child: Text("Cancel")),
              ],
            ),
        ],
      )
          : AppBar(
        title: Text(widget.album.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _sortPhotos,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'Most Liked', child: Text("Most Liked")),
              const PopupMenuItem(value: 'Newest', child: Text("Newest")),
              const PopupMenuItem(value: 'Oldest', child: Text("Oldest")),
              const PopupMenuItem(value: 'Name', child: Text("Name (A-Z)")),
            ],
          ),
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteAlbum,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.album.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('${widget.album.createdAt.day}/${widget.album.createdAt.month}/${widget.album.createdAt.year}', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Expanded(
            child: _albumPhotos.isEmpty
                ? const Center(child: Text("No photos in this album"))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
              itemCount: _albumPhotos.length,
              itemBuilder: (context, index) {
                final photo = _albumPhotos[index];
                final isSelected = _selectedPhotoIds.contains(photo.id);
                return GestureDetector(
                  onLongPress: () => _toggleSelectPhoto(photo.id),
                  onTap: () => _isSelectMode ? _toggleSelectPhoto(photo.id) : Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo))).then((_) => _fetchAlbumDetails()),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: ColorFiltered(colorFilter: ColorFilter.mode(isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent, BlendMode.srcOver), child: _buildImage(photo, theme))),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(photo.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${photo.dateAdded.day}/${photo.dateAdded.month}', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                                      Row(
                                        children: [
                                          Icon(photo.isLiked ? Icons.favorite : Icons.favorite_border, size: 12, color: photo.isLiked ? Colors.red : scheme.onSurfaceVariant),
                                          const SizedBox(width: 2),
                                          Text('${photo.likes}', style: const TextStyle(fontSize: 10)),
                                          const SizedBox(width: 6),
                                          Icon(Icons.comment_outlined, size: 12, color: scheme.onSurfaceVariant),
                                          const SizedBox(width: 2),
                                          Text('${photo.commentsCount}', style: const TextStyle(fontSize: 10)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSelected) Center(child: Icon(Icons.check_circle, color: scheme.primary, size: 36)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
