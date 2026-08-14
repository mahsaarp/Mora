import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mora/services/SocketService.dart';
import 'package:mora/screens/album_detail_screen.dart';
import 'package:mora/utils/explore_mock_data.dart';
import 'package:mora/utils/shimmer_box.dart';
import 'package:mora/screens/photo_detail_screen.dart';
import 'package:mora/pages/profile_page.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<ExplorePhoto> allPhotos = [];
  List<ExploreAlbum> allAlbums = [];
  List<Map<String, dynamic>> allUsers = [];

  List<ExplorePhoto> filteredPhotos = [];
  List<ExploreAlbum> filteredAlbums = [];
  List<Map<String, dynamic>> filteredUsers = [];

  bool _isLoading = true;
  String sortBy = 'date';
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchPhotos(),
      _fetchAlbums(),
      _fetchUsers(),
    ]);
    _applySearchAndSort();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchPhotos() async {
    try {
      final response = await SocketService.getHomePhotos();
      if (response['statusCode'] == 200 || response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        allPhotos = data.map((json) => ExplorePhoto.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching photos: $e");
    }
  }

  Future<void> _fetchAlbums() async {
    try {
      final response = await SocketService.getAlbums();
      if (response['statusCode'] == 200 || response['success'] == true) {
        final dynamic data = response['data'];
        List<dynamic> albumsData = [];
        if (data is List) {
          albumsData = data;
        } else if (data is Map && data.containsKey('albums')) {
          albumsData = data['albums'];
        }
        allAlbums = albumsData.map((json) => ExploreAlbum.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching albums: $e");
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await SocketService.getAllUsers();
      if (response['statusCode'] == 200 || response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        allUsers = data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  void _applySearchAndSort() {
    setState(() {
      filteredPhotos = allPhotos.where((p) =>
      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
      _sortPhotos();

      filteredAlbums = allAlbums.where((a) =>
          a.title.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();

      filteredUsers = allUsers.where((u) =>
          (u['username'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    });
  }

  void _sortPhotos() {
    if (sortBy == 'date') {
      filteredPhotos.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    } else if (sortBy == 'name') {
      filteredPhotos.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (sortBy == 'likes') {
      filteredPhotos.sort((a, b) => b.likes.compareTo(a.likes));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildImage(String imageUrl, ThemeData theme) {
    if (imageUrl.isEmpty) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(Icons.image, color: theme.colorScheme.onSurfaceVariant),
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
        child: Icon(Icons.broken_image, color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildPhotoItemImage(ExplorePhoto photo, ThemeData theme) {
    if (photo.imageUrl.startsWith('assets/')) {
      return Image.asset(photo.imageUrl, fit: BoxFit.cover);
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: SocketService.downloadPhoto(int.tryParse(photo.id) ?? 0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerBox(width: double.infinity, height: double.infinity, borderRadius: 0);
        }
        if (snapshot.hasData && (snapshot.data!['statusCode'] == 200 || snapshot.data!['success'] == true)) {
          final base64Data = snapshot.data!['data']?['fileData'] ?? '';
          if (base64Data.isNotEmpty) {
            return Image.memory(base64Decode(base64Data), fit: BoxFit.cover);
          }
        }
        return Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: theme.colorScheme.onSurfaceVariant),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAllData),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (val) {
              setState(() => sortBy = val);
              _sortPhotos();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'likes', child: Text('Sort by Likes')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _searchQuery = val;
                    _applySearchAndSort();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search photos, albums or users...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                      _applySearchAndSort();
                    })
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: scheme.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: scheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Photos'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Users'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _fetchAllData, child: _buildPhotosTab(theme)),
          _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _fetchAllData, child: _buildAlbumsTab(theme)),
          _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _fetchAllData, child: _buildUsersTab(theme)),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(ThemeData theme) {
    if (filteredPhotos.isEmpty) return const Center(child: Text("No photos found"));
    final scheme = theme.colorScheme;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85),
      itemCount: filteredPhotos.length,
      itemBuilder: (context, index) {
        final photo = filteredPhotos[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo))).then((_) => _fetchAllData()),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildPhotoItemImage(photo, theme)),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(photo.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
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
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab(ThemeData theme) {
    final scheme = theme.colorScheme;
    if (filteredAlbums.isEmpty) return const Center(child: Text("No albums found"));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filteredAlbums.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final album = filteredAlbums[index];
        final String? thumbnail = album.imageUrls.isNotEmpty ? album.imageUrls.first : null;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album))),
          child: Container(
            decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: scheme.outlineVariant)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: thumbnail != null
                      ? _buildImage(thumbnail, theme)
                      : Container(color: scheme.surfaceContainerHighest, child: const Icon(Icons.photo_album_outlined)),
                ),
              ),
              title: Text(album.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${album.photoCount} photos'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        );
      },
    );
  }

  ImageProvider _buildAvatarProvider(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    }
    if (avatarPath.startsWith('assets/')) {
      return AssetImage(avatarPath);
    }
    return NetworkImage('${SocketService.baseUrl}/$avatarPath');
  }

  Widget _buildUsersTab(ThemeData theme) {
    final scheme = theme.colorScheme;
    if (filteredUsers.isEmpty) return const Center(child: Text("No users found"));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final username = user['username'] ?? 'Unknown';
        final avatarRoute = user['avatarRoute'] as String?;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: _buildAvatarProvider(avatarRoute),
              onBackgroundImageError: (e, s) => const Icon(Icons.person),
            ),
            title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(viewUsername: username))),
          ),
        );
      },
    );
  }
}
