import 'package:flutter/material.dart';
import '../utils/explore_mock_data.dart';
import '../utils/shimmer_box.dart';
import 'photo_detail_screen.dart';

class AlbumDetailScreen extends StatelessWidget {
  final ExploreAlbum album;

  const AlbumDetailScreen({super.key, required this.album});

  Widget _buildImage(String urlOrPath, ThemeData theme) {
    final scheme = theme.colorScheme;
    if (urlOrPath.startsWith('http')) {
      return Image.network(
        urlOrPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerBox(width: double.infinity, height: double.infinity);
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image, color: scheme.onSurfaceVariant),
        ),
      );
    }
    return Image.asset(
      urlOrPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_not_supported, color: scheme.onSurfaceVariant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final List<ExplorePhoto> albumPhotos = initialMockPhotos
        .where((photo) => album.imageUrls.contains(photo.imageUrl))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Album')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${album.createdAt.day}/${album.createdAt.month}/${album.createdAt.year}',
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: albumPhotos.length,
              itemBuilder: (context, index) {
                final photo = albumPhotos[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)),
                  ),
                  child: Card(
                    color: scheme.surface,
                    clipBehavior: Clip.antiAlias,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${photo.dateAdded.day}/${photo.dateAdded.month}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        size: 12,
                                        color: scheme.error,
                                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
