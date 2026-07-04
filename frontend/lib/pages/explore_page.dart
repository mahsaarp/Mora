import 'package:flutter/material.dart';
import '../screens/album_detail_screen.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import '../screens/photo_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<ExplorePhoto> photos = List.from(initialMockPhotos);
  bool isSelectionMode = false;
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

  Widget _buildImage(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(width: double.infinity, height: double.infinity);
        },
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
      );
    } else {
      return Image.asset(
        urlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
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

  void _cancelSelection() {
    setState(() {
      isSelectionMode = false;
      for (var p in photos) p.isSelected = false;
    });
  }

  List<ExplorePhoto> get _selectedPhotos => photos.where((p) => p.isSelected).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode ? Text('${_selectedPhotos.length} selected') : const Text('Explore'),
        leading: isSelectionMode ? IconButton(icon: const Icon(Icons.close), onPressed: _cancelSelection) : null,
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Photos'), Tab(text: 'Albums')]),
        actions: [
          if (!isSelectionMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (val) { sortBy = val; _sortPhotos(); },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
                const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                const PopupMenuItem(value: 'likes', child: Text('Sort by Likes')),
              ],
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPhotosTab(), _buildAlbumsTab()],
      ),
      bottomNavigationBar: isSelectionMode ? _buildSelectionActionBar() : null,
    );
  }

  Widget _buildPhotosTab() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GestureDetector(
          onLongPress: () => setState(() { isSelectionMode = true; photo.isSelected = true; }),
          onTap: () {
            if (isSelectionMode) {
              setState(() {
                photo.isSelected = !photo.isSelected;
                if (_selectedPhotos.isEmpty) isSelectionMode = false;
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)),
              ).then((_) => setState(() {}));
            }
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: photo.isSelected ? Colors.blue : Colors.transparent, width: 2),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildImage(photo.imageUrl)),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(photo.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${photo.dateAdded.day}/${photo.dateAdded.month}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              Row(children: [const Icon(Icons.favorite, size: 12, color: Colors.red), const SizedBox(width: 2), Text('${photo.likes}', style: const TextStyle(fontSize: 10))]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isSelectionMode)
                  Positioned(top: 8, left: 8, child: CircleAvatar(radius: 12, backgroundColor: photo.isSelected ? Colors.blue : Colors.black45, child: photo.isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: mockAlbums.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final album = mockAlbums[index];
        final coverImage = album.imageUrls.isNotEmpty ? album.imageUrls.first : '';

        return InkWell(
          borderRadius: BorderRadius.circular(8),
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: _buildImage(coverImage),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${album.photoCount} photos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionActionBar() {return Container(); }
  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {return Container(); }
  void _showMoveToAlbumDialog() {}
}
