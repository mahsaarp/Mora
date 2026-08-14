import '../utils/explore_mock_data.dart';

class UserProfile {
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool isAdmin;
  final List<ExplorePhoto> photos;
  final List<ExploreAlbum> albums;

  UserProfile({
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.isAdmin,
    required this.photos,
    required this.albums,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json;
    return UserProfile(
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? data['display_name'] ?? data['username'] ?? '',
      avatarUrl: data['avatar_url'] ?? '',
      isAdmin: data['is_admin'] ?? false,
      photos: (data['photos'] as List? ?? [])
          .map((item) => ExplorePhoto.fromJson(item))
          .toList(),
      albums: (data['albums'] as List? ?? [])
          .map((item) => ExploreAlbum.fromJson(item))
          .toList(),
    );
  }
}
