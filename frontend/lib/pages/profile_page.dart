import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/SocketService.dart';
import '../services/session_manager.dart';
import '../screens/album_detail_screen.dart';
import '../screens/photo_detail_screen.dart';
import '../screens/create_album_screen.dart';
import '../screens/log_in_screen.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import '../main.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String? viewUsername;
  final String? viewAvatar;

  const ProfilePage({super.key, this.viewUsername, this.viewAvatar});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool get isOwnProfile => widget.viewUsername == null;
  bool _isLoading = true;
  bool isAdmin = false;
  int selectedTabIndex = 0;

  String? _currentUsername;
  String? _currentDisplayName;
  String? _currentAvatar;
  String? _currentRank;

  List<ExplorePhoto> _profilePhotos = [];
  List<ExploreAlbum> _profileAlbums = [];

  bool _isSelectMode = false;
  final Set<String> _selectedPhotoIds = {};

  @override
  void initState() {
    super.initState();
    _currentUsername = widget.viewUsername ?? SocketService.loggedInUsername;
    _currentAvatar = widget.viewAvatar;
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final targetUser = widget.viewUsername ?? SocketService.loggedInUsername ?? "";
      final response = await SocketService.getUserProfile(targetUser);

      if (response['statusCode'] == 200 || response['success'] == true) {
        final data = response['data'] ?? {};
        if (!mounted) return;

        if (isOwnProfile) {
          var rawId = data['userId'] ?? data['id'] ?? response['userId'] ?? response['id'] ?? data['user']?['id'];
          int? id;
          if (rawId != null) {
            id = int.tryParse(rawId.toString());
          }
          if (id != null && id > 0) {
            await SessionManager().setUser(id, data['username'] ?? SocketService.loggedInUsername ?? "");
          }
        }

        setState(() {
          isAdmin = data['is_admin'] ?? false;
          _currentRank = data['rank'];
          final incomingDisplayName = (data['displayName'] ?? data['display_name'] ?? '').toString();
          if (isOwnProfile) {
            _currentUsername = data['username'] ?? SocketService.loggedInUsername;
            _currentDisplayName = incomingDisplayName.isNotEmpty ? incomingDisplayName : (_currentUsername ?? 'User');
            _currentAvatar = data['avatarRoute'] ?? data['avatar'];
          } else {
            _currentUsername = data['username'] ?? widget.viewUsername;
            _currentDisplayName = incomingDisplayName.isNotEmpty ? incomingDisplayName : (_currentUsername ?? 'User');
            _currentAvatar = data['avatarRoute'] ?? data['avatar'] ?? widget.viewAvatar;
          }

          _profilePhotos = (data['photos'] as List? ?? []).map((json) => ExplorePhoto.fromJson(json)).toList();
          _profileAlbums = (data['albums'] as List? ?? []).map((json) => ExploreAlbum.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getColorFromSlug(String slug) {
    switch (slug) {
      case 'blue': return const Color(0xFFAED9E0);
      case 'pink': return const Color(0xFFFAC9B8);
      case 'yellow': return const Color(0xFFFFF4BD);
      case 'green':
      default: return const Color(0xFF6C8E61);
    }
  }

  String _getSlugFromColor(Color color) {
    if (color == const Color(0xFFAED9E0)) return 'blue';
    if (color == const Color(0xFFFAC9B8)) return 'pink';
    if (color == const Color(0xFFFFF4BD)) return 'yellow';
    return 'green';
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: const Text("Theme Mode"),
                    trailing: Switch(
                      value: themeNotifier.value == ThemeMode.dark,
                      onChanged: (val) {
                        themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                        setModalState(() {});
                        SocketService.updateSettings(themeMode: val ? 'dark' : 'light');
                      },
                    ),
                  ),
                  const Divider(),
                  const Text("Theme Color", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _colorOption(const Color(0xFF6C8E61), "Green", setModalState),
                      _colorOption(const Color(0xFFAED9E0), "Blue", setModalState),
                      _colorOption(const Color(0xFFFAC9B8), "Pink", setModalState),
                      _colorOption(const Color(0xFFFFF4BD), "Yellow", setModalState),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text("Log Out"),
                    onTap: () async {
                      Navigator.pop(context);
                      final username = SocketService.loggedInUsername ?? "";
                      await SocketService.logout(username);
                      await SessionManager().clear();
                      SocketService.loggedInUsername = null;
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text("Delete Account"),
                          content: const Text("All your photos and albums will be gone forever. Continue?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        Navigator.pop(context);
                        await SocketService.deleteAccount(SocketService.loggedInUsername ?? "");
                        await SessionManager().clear();
                        SocketService.loggedInUsername = null;
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInScreen()), (r) => false);
                      }
                    },
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _colorOption(Color color, String name, StateSetter setModalState) {
    bool isSelected = themeColorNotifier.value == color;
    return GestureDetector(
      onTap: () {
        themeColorNotifier.value = color;
        setModalState(() {});
        SocketService.updateSettings(themeColor: _getSlugFromColor(color));
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
        ),
        child: CircleAvatar(backgroundColor: color, radius: 18),
      ),
    );
  }

  void _toggleSelectPhoto(String photoId) {
    setState(() {
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
        if (_selectedPhotoIds.isEmpty) _isSelectMode = false;
      } else {
        _selectedPhotoIds.add(photoId);
      }
    });
  }

  Future<void> _deleteSelectedPhotosPermanently() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Permanent Delete"),
        content: Text("Delete ${_selectedPhotoIds.length} photos from everywhere?"),
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
    setState(() {
      _isSelectMode = false;
      _selectedPhotoIds.clear();
    });
    _fetchProfileData();
  }

  Future<void> _moveToAlbum() async {
    if (_profileAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No albums available.")));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profileAlbums.length,
        itemBuilder: (ctx, idx) {
          final album = _profileAlbums[idx];
          return ListTile(
            leading: const Icon(Icons.photo_album),
            title: Text(album.title),
            onTap: () async {
              Navigator.pop(ctx);
              final targetAlbumId = int.tryParse(album.id) ?? 0;
              for (String photoId in _selectedPhotoIds) {
                await SocketService.addPhotoToAlbum(albumId: targetAlbumId, photoId: int.tryParse(photoId) ?? 0);
              }
              setState(() {
                _isSelectMode = false;
                _selectedPhotoIds.clear();
              });
              _fetchProfileData();
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final String headerTitle = isOwnProfile ? "My Profile" : (_currentUsername ?? "User");
    final String displayUsername = _currentDisplayName ?? _currentUsername ?? (isOwnProfile ? "My Profile" : "User");

    return Scaffold(
      appBar: _isSelectMode
          ? AppBar(
        backgroundColor: scheme.primaryContainer,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _isSelectMode = false; _selectedPhotoIds.clear(); })),
        title: Text("${_selectedPhotoIds.length} Selected"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'delete') _deleteSelectedPhotosPermanently();
              if (val == 'move') _moveToAlbum();
              if (val == 'cancel') setState(() { _isSelectMode = false; _selectedPhotoIds.clear(); });
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
              const PopupMenuItem(value: 'move', child: Text("Move to album")),
              const PopupMenuItem(value: 'cancel', child: Text("Cancel")),
            ],
          ),
        ],
      )
          : AppBar(
        title: Text(headerTitle),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchProfileData),
          if (isOwnProfile)
            IconButton(icon: const Icon(Icons.settings), onPressed: _showSettingsSheet),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 25),
              CircleAvatar(radius: 55, backgroundImage: _getAvatarProvider(_currentAvatar)),
              const SizedBox(height: 15),
              Text(displayUsername, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              if (_currentUsername != null && _currentUsername != displayUsername)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_currentUsername!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14)),
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(color: scheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(_currentRank ?? (isAdmin ? "ADMIN" : "CREATOR"), style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
              ),
              if (isOwnProfile) ...[
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                    _fetchProfileData();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit Profile"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem("Posts", _profilePhotos.length),
                  _statItem("Albums", _profileAlbums.length),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withOpacity(0.6), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    _tabButton("Photos", 0, scheme),
                    _tabButton("Albums", 1, scheme),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              selectedTabIndex == 0 ? _buildPhotosGrid(theme) : _buildAlbumsList(theme),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getAvatarProvider(String? url) {
    if (url == null || url.isEmpty) return const AssetImage("assets/images/profile.jpg");
    if (url.startsWith('http')) return NetworkImage(url);
    if (url.startsWith('assets/')) return AssetImage(url);
    if (url.contains('uploads/')) return NetworkImage('${SocketService.baseUrl}/$url');

    try {
      String base64String = url;
      if (url.contains(',')) {
        base64String = url.split(',')[1];
      }
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      return const AssetImage("assets/images/profile.jpg");
    }
  }

  Widget _statItem(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _tabButton(String text, int index, ColorScheme scheme) {
    bool selected = selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: selected ? scheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(15)),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: selected ? scheme.onPrimary : scheme.onSurface, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPhotosGrid(ThemeData theme) {
    if (_profilePhotos.isEmpty) return const Padding(padding: EdgeInsets.only(top: 20), child: Text("No photos available."));
    final scheme = theme.colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _profilePhotos.length,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85
      ),
      itemBuilder: (context, index) {
        final photo = _profilePhotos[index];
        final isSelected = _selectedPhotoIds.contains(photo.id);
        return GestureDetector(
          onLongPress: () {
            if (isOwnProfile) {
              setState(() {
                _isSelectMode = true;
                _selectedPhotoIds.add(photo.id);
              });
            }
          },
          onTap: () {
            if (_isSelectMode) {
              _toggleSelectPhoto(photo.id);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo))).then((_) => _fetchProfileData());
            }
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent, BlendMode.srcOver),
                        child: _buildImageItem(photo, theme),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(photo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${photo.dateAdded.day}/${photo.dateAdded.month}', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                              Row(
                                children: [
                                  Icon(photo.isLiked ? Icons.favorite : Icons.favorite_border, size: 12, color: photo.isLiked ? Colors.red : scheme.onSurfaceVariant),
                                  const SizedBox(width: 2),
                                  Text('${photo.likes}', style: TextStyle(fontSize: 10, color: scheme.onSurface)),
                                  const SizedBox(width: 6),
                                  Icon(Icons.comment_outlined, size: 12, color: scheme.onSurfaceVariant),
                                  const SizedBox(width: 2),
                                  Text('${photo.commentsCount}', style: TextStyle(fontSize: 10, color: scheme.onSurface)),
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
    );
  }

  Widget _buildImageItem(ExplorePhoto photo, ThemeData theme) {
    if (photo.imageUrl.startsWith('assets/')) return Image.asset(photo.imageUrl, fit: BoxFit.cover);
    return FutureBuilder<Map<String, dynamic>>(
      future: SocketService.downloadPhoto(int.tryParse(photo.id) ?? 0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0);
        if (snapshot.hasData && (snapshot.data!['statusCode'] == 200 || snapshot.data!['success'] == true)) {
          final base64Data = snapshot.data!['data']?['fileData'] ?? '';
          if (base64Data.isNotEmpty) return Image.memory(base64Decode(base64Data), fit: BoxFit.cover);
        }
        return Container(color: theme.colorScheme.surfaceContainerHighest, child: const Icon(Icons.broken_image));
      },
    );
  }

  Widget _buildAlbumsList(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Column(
      children: [
        if (isOwnProfile)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.create_new_folder),
              label: const Text("Create New Album"),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateAlbumScreen(availablePhotos: _profilePhotos)));
                _fetchProfileData();
              },
            ),
          ),
        if (_profileAlbums.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 20), child: Text("No albums available."))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _profileAlbums.length,
            itemBuilder: (context, index) {
              final album = _profileAlbums[index];
              final String? thumbnail = album.imageUrls.isNotEmpty ? album.imageUrls.first : null;
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: _buildAlbumThumbnail(thumbnail, theme),
                  ),
                ),
                title: Text(album.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${album.photoCount} Photos"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album))).then((_) => _fetchProfileData()),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAlbumThumbnail(String? imageUrl, ThemeData theme) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.photo_album_outlined),
      );
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image));
    }
    return Image.network(
      '${SocketService.baseUrl}/$imageUrl',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
