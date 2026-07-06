import 'package:flutter/material.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import '../screens/photo_detail_screen.dart';
import '../screens/album_detail_screen.dart';
import '../pages/profile_page.dart';

class MockUser {
  final String username;
  final String avatar;

  MockUser({required this.username, required this.avatar});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MockUser && runtimeType == other.runtimeType && username == other.username;

  @override
  int get hashCode => username.hashCode;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<ExplorePhoto> _allPhotos = [];
  List<ExploreAlbum> _allAlbums = [];
  List<MockUser> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _allPhotos = List.from(initialMockPhotos);
    _allAlbums = List.from(mockAlbums);

    final Set<MockUser> userSet = {};
    for (var photo in _allPhotos) {
      userSet.add(MockUser(username: photo.username, avatar: photo.userAvatar));
    }
    _allUsers = userSet.toList();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildImage(String urlOrPath, ThemeData theme) {
    final scheme = theme.colorScheme;
    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: scheme.onSurfaceVariant),
        ),
      );
    } else {
      return Image.asset(
        urlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.image_not_supported, color: scheme.onSurfaceVariant),
        ),
      );
    }
  }

  List<ExplorePhoto> get _filteredPhotos {
    if (_searchQuery.isEmpty) return _allPhotos;
    return _allPhotos.where((photo) {
      final nameMatch = photo.name.toLowerCase().contains(_searchQuery);
      final tagMatch = photo.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
      return nameMatch || tagMatch;
    }).toList();
  }

  List<ExploreAlbum> get _filteredAlbums {
    if (_searchQuery.isEmpty) return _allAlbums;
    return _allAlbums.where((album) {
      return album.title.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<MockUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return _allUsers;
    return _allUsers.where((user) {
      return user.username.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 140,
          title: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Search by title, tag, or user...",
                    hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.7)),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: scheme.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: scheme.onSurfaceVariant),
                      onPressed: () => _searchController.clear(),
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: scheme.onPrimary,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  tabs: const [
                    Tab(text: "Photos"),
                    Tab(text: "Albums"),
                    Tab(text: "Users"),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPhotosGrid(theme),
            _buildAlbumsList(theme),
            _buildUsersList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosGrid(ThemeData theme) {
    final scheme = theme.colorScheme;
    final filtered = _filteredPhotos;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No photos found.",
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final photo = filtered[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)),
            ).then((_) => setState(() {}));
          },
          child: Card(
            color: scheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(photo.imageUrl, theme),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          scheme.scrim.withOpacity(0.80),
                          scheme.scrim.withOpacity(0.00),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          photo.name,
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${photo.username}',
                          style: TextStyle(
                            color: scheme.onPrimary.withOpacity(0.85),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumsList(ThemeData theme) {
    final scheme = theme.colorScheme;
    final filtered = _filteredAlbums;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No albums found.",
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final album = filtered[index];
        final coverImage = album.imageUrls.isNotEmpty ? album.imageUrls.first : '';

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildImage(coverImage, theme),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${album.photoCount} photos',
                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersList(ThemeData theme) {
    final scheme = theme.colorScheme;
    final filtered = _filteredUsers;

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No users found.",
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final user = filtered[index];
        return Card(
          color: scheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: _buildImage(user.avatar, theme),
              ),
            ),
            title: Text(
              user.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            subtitle: Text(
              "User / Creator",
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    viewUsername: user.username,
                    viewAvatar: user.avatar,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
