import 'package:flutter/material.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';

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

  // ————————————————————————————————————————————
  // ————————————————————————————————————————————
  Widget _buildImage(String urlOrPath) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(width: double.infinity, height: double.infinity);
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.asset(
        urlOrPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.grey),
                SizedBox(height: 4),
                Text('Not found', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          );
        },
      );
    }
  }

  // ————————————————————————————————————————————
  //  sort
  // ————————————————————————————————————————————
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

  // ————————————————————————————————————————————
  //  selection
  // ————————————————————————————————————————————
  void _cancelSelection() {
    setState(() {
      isSelectionMode = false;
      for (var p in photos) {
        p.isSelected = false;
      }
    });
  }

  List<ExplorePhoto> get _selectedPhotos =>
      photos.where((p) => p.isSelected).toList();

  // ————————————————————————————————————————————
  //  UI
  // ————————————————————————————————————————————
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text('${_selectedPhotos.length} item(s) selected')
            : const Text('Explore'),
        leading: isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancelSelection,
        )
            : null,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Photos'),
            Tab(text: 'Albums'),
          ],
        ),
        actions: [
          if (!isSelectionMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                sortBy = value;
                _sortPhotos();
              },
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
        children: [
          _buildPhotosTab(),
          _buildAlbumsTab(),
        ],
      ),

      bottomNavigationBar:
      isSelectionMode ? _buildSelectionActionBar() : null,
    );
  }

  // ————————————————————————————————————————————
  //  Photos Tab
  // ————————————————————————————————————————————
  Widget _buildPhotosTab() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),

      itemCount: photos.length,

      itemBuilder: (context, index) {
        final photo = photos[index];

        return GestureDetector(
          onLongPress: () {
            setState(() {
              isSelectionMode = true;
              photo.isSelected = true;
            });
          },
          onTap: () {
            if (isSelectionMode) {
              setState(() {
                photo.isSelected = !photo.isSelected;
                if (_selectedPhotos.isEmpty) {
                  isSelectionMode = false;
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${photo.name} details...')),
              );
            }
          },

          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: photo.isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
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
                          Text(
                            photo.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${photo.dateAdded.year}/${photo.dateAdded.month}/${photo.dateAdded.day}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.favorite, size: 12, color: Colors.red),
                                  const SizedBox(width: 2),
                                  Text('${photo.likes}', style: const TextStyle(fontSize: 10)),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (isSelectionMode)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: photo.isSelected ? Colors.blue : Colors.black45,
                      child: photo.isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ————————————————————————————————————————————
  //  Albums Tab
  // ————————————————————————————————————————————
  Widget _buildAlbumsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: mockAlbums.length,
      itemBuilder: (context, index) {
        final album = mockAlbums[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening album: ${album.title}')),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      children: List.generate(
                        album.imageUrls.length > 3 ? 3 : album.imageUrls.length,
                            (imgIdx) => Positioned(
                          left: imgIdx * 8,
                          top: imgIdx * 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: _buildImage(album.imageUrls[imgIdx]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(album.title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${album.photoCount} Photos',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ————————————————————————————————————————————
  //  Selection Bar
  // ————————————————————————————————————————————
  Widget _buildSelectionActionBar() {
    return Container(
      color: Theme.of(context).primaryColorDark,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(Icons.delete, 'Delete', () {
              setState(() {
                photos.removeWhere((p) => p.isSelected);
                _cancelSelection();
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Selected photos deleted successfully.')));
            }),

            _buildActionItem(Icons.folder_open, 'Move to Album', () {
              _showMoveToAlbumDialog();
            }),

            _buildActionItem(Icons.share, 'Share', () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sharing ${_selectedPhotos.length} photo(s)...')),
              );
              _cancelSelection();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _showMoveToAlbumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move to Album'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mockAlbums.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(mockAlbums[index].title),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Moved ${_selectedPhotos.length} items to "${mockAlbums[index].title}"',
                        ),
                      ),
                    );
                    _cancelSelection();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
