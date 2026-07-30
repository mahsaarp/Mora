import 'package:flutter/material.dart';
import '../screens/album_detail_screen.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import '../screens/photo_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key}); //constructor

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<ExplorePhoto> photos = List.from(initialMockPhotos); //creates a copy list
  String sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
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

  void _sortPhotos() {
    setState(() {
      if (sortBy == 'date') {
        photos.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      } else if (sortBy == 'name') {
        photos.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else if (sortBy == 'likes') {
        photos.sort((a, b) => b.likes.compareTo(a.likes));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: scheme.onPrimary),
            onSelected: (val) {
              sortBy = val;
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
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: scheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Photos'),
                Tab(text: 'Albums'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhotosTab(theme),
          _buildAlbumsTab(theme),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(ThemeData theme) {
    final scheme = theme.colorScheme;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)),
            ).then((_) => setState(() {}));
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildImage(photo.imageUrl, theme)),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${photo.dateAdded.day}/${photo.dateAdded.month}/${photo.dateAdded.year}',
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.favorite, size: 12, color: Colors.red.shade400),
                              const SizedBox(width: 2),
                              Text(
                                '${photo.likes}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: scheme.onSurface,
                                ),
                              ),
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

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: mockAlbums.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final album = mockAlbums[index];
        final coverImage = album.imageUrls.isNotEmpty ? album.imageUrls.first : '';

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlbumDetailScreen(album: album),
              ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
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
}
