import 'package:flutter/material.dart';
import '../services/SocketService.dart';
import '../screens/album_detail_screen.dart';
import '../screens/photo_detail_screen.dart';
import '../utils/explore_mock_data.dart';
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

  List<ExplorePhoto> _profilePhotos = [];
  List<ExploreAlbum> _profileAlbums = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final targetUser = widget.viewUsername ?? "me"; 
      final response = await SocketService.getUserProfile(targetUser);

      if (response['statusCode'] == 200 || response['success'] == true) {
        final data = response['data'] ?? {};
        setState(() {
          isAdmin = data['is_admin'] ?? false;
          
          _profilePhotos = (data['photos'] as List? ?? []).map((json) => ExplorePhoto(
            id: json['id']?.toString() ?? '',
            name: json['title'] ?? '',
            imageUrl: json['image_url'] ?? '',
            dateAdded: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
            likes: json['likes'] ?? 0,
            caption: json['description'] ?? '',
            tags: List<String>.from(json['tags'] ?? []),
            username: data['username'] ?? '',
            userAvatar: data['avatar_url'] ?? 'assets/images/profile.jpg',
          )).toList();

          _profileAlbums = (data['albums'] as List? ?? []).map((json) => ExploreAlbum(
            id: json['id']?.toString() ?? '',
            title: json['title'] ?? '',
            imageUrls: List<String>.from(json['image_urls'] ?? []),
            photoCount: json['photo_count'] ?? 0,
            createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
          )).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final String displayName = isOwnProfile ? "My Profile" : (widget.viewUsername ?? "User");

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchProfileData),
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
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: (widget.viewAvatar != null && widget.viewAvatar!.startsWith('http'))
                        ? NetworkImage(widget.viewAvatar!)
                        : const AssetImage("assets/images/profile.jpg") as ImageProvider,
                  ),
                  const SizedBox(height: 15),
                  Text(displayName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(color: scheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(isAdmin ? "ADMIN" : "CREATOR", style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 25),
                  _buildStatsRow(),
                  const SizedBox(height: 30),
                  _buildTabBar(scheme),
                  const SizedBox(height: 20),
                  _buildTabContent(theme),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem("Posts", _profilePhotos.length),
        _statItem("Albums", _profileAlbums.length),
      ],
    );
  }

  Widget _statItem(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTabBar(ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest.withOpacity(0.6), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _tabButton("Photos", 0, scheme),
          _tabButton("Albums", 1, scheme),
        ],
      ),
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

  Widget _buildTabContent(ThemeData theme) {
    if (selectedTabIndex == 0) return _buildPhotosGrid(theme);
    return _buildAlbumsList(theme);
  }

  Widget _buildPhotosGrid(ThemeData theme) {
    if (_profilePhotos.isEmpty) return const Text("No photos available.");
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _profilePhotos.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        final photo = _profilePhotos[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photo.imageUrl.startsWith('http') 
                ? Image.network(photo.imageUrl, fit: BoxFit.cover) 
                : Image.asset("assets/images/placeholder.jpg", fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildAlbumsList(ThemeData theme) {
    if (_profileAlbums.isEmpty) return const Text("No albums available.");
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _profileAlbums.length,
      itemBuilder: (context, index) {
        final album = _profileAlbums[index];
        return ListTile(
          title: Text(album.title),
          subtitle: Text("${album.photoCount} Photos"),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album))),
        );
      },
    );
  }
}
