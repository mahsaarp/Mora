import 'package:flutter/material.dart';
import '../services/SocketService.dart';
import '../utils/explore_mock_data.dart';
import '../screens/photo_detail_screen.dart';
import '../pages/profile_page.dart';

class MockUser {
  final String username;
  final String avatar;

  MockUser({required this.username, required this.avatar});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  List<ExplorePhoto> _photos = [];
  List<MockUser> _users = [];

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _photos = [];
        _users = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await SocketService.search(query);
      // هماهنگی با ساختار جدید پاسخ سرور
      if (response['statusCode'] == 200 || response['success'] == true) {
        final data = response['data'] ?? {};
        setState(() {
          _photos = (data['photos'] as List? ?? []).map((json) => ExplorePhoto(
            id: json['id']?.toString() ?? '',
            name: json['title'] ?? 'Untitled',
            imageUrl: json['image_url'] ?? '',
            dateAdded: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
            likes: json['likes'] ?? 0,
            caption: json['description'] ?? '',
            tags: List<String>.from(json['tags'] ?? []),
            username: json['owner_username'] ?? 'Unknown',
            userAvatar: 'assets/images/default_avatar.png',
          )).toList();

          _users = (data['users'] as List? ?? []).map((json) => MockUser(
            username: json['username'] ?? '',
            avatar: json['avatar_url'] ?? 'assets/images/default_avatar.png',
          )).toList();
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 120,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(25)),
            child: TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: "Search photos or users...",
                border: InputBorder.none,
                icon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _performSearch(""); }),
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [Tab(text: "Photos"), Tab(text: "Users")],
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              children: [
                _buildPhotosGrid(theme),
                _buildUsersList(theme),
              ],
            ),
      ),
    );
  }

  Widget _buildPhotosGrid(ThemeData theme) {
    if (_photos.isEmpty) return const Center(child: Text("No photos found."));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photo.imageUrl.startsWith('http') 
                ? Image.network(photo.imageUrl, fit: BoxFit.cover) 
                : Container(color: Colors.grey[300], child: const Icon(Icons.image)),
          ),
        );
      },
    );
  }

  Widget _buildUsersList(ThemeData theme) {
    if (_users.isEmpty) return const Center(child: Text("No users found."));
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: const CircleAvatar(backgroundImage: AssetImage("assets/images/profile.jpg")),
          title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(viewUsername: user.username))),
        );
      },
    );
  }
}
