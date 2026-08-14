import '../model/comment.dart';
import '../services/session_manager.dart';

class ExplorePhoto {
  final String id;
  String name;
  final String imageUrl;
  final DateTime dateAdded;
  int likes;
  int commentsCount;
  bool isSelected;
  bool isLiked;

  String caption;
  List<String> tags;
  final String username;
  final String userAvatar;
  final bool isOwner;

  bool allowComments;
  List<Comment> comments;

  ExplorePhoto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.dateAdded,
    required this.likes,
    this.commentsCount = 0,
    this.isSelected = false,
    required this.caption,
    required this.tags,
    required this.username,
    required this.userAvatar,
    this.isOwner = false,
    this.allowComments = true,
    this.isLiked = false,
    this.comments = const [],
  });

  factory ExplorePhoto.fromJson(Map<String, dynamic> json) {
    final currentUserId = SessionManager().userId;

    final id = (json['id'] ?? json['photoId'] ?? json['photo_id'] ?? '').toString();

    final userLikedIdsRaw = json['userLikedIds'] ?? json['liked_user_ids'] ?? [];
    final List<dynamic> userLikedIds = userLikedIdsRaw is List ? userLikedIdsRaw : [];

    int likesCount = 0;
    if (json['likes'] != null) {
      likesCount = int.tryParse(json['likes'].toString()) ?? 0;
    } else if (json['likesCount'] != null) {
      likesCount = int.tryParse(json['likesCount'].toString()) ?? 0;
    } else if (json['likes_count'] != null) {
      likesCount = int.tryParse(json['likes_count'].toString()) ?? 0;
    } else {
      likesCount = userLikedIds.length;
    }

    bool isLiked = false;
    if (currentUserId != null) {
      isLiked = userLikedIds.any((element) => element.toString() == currentUserId.toString());
    }
    if (!isLiked) {
      isLiked = json['isLiked'] ?? json['is_liked'] ?? false;
    }

    int cCount = 0;
    if (json['commentsCount'] != null) {
      cCount = int.tryParse(json['commentsCount'].toString()) ?? 0;
    } else if (json['comments_count'] != null) {
      cCount = int.tryParse(json['comments_count'].toString()) ?? 0;
    } else if (json['commentIds'] != null && json['commentIds'] is List) {
      cCount = (json['commentIds'] as List).length;
    } else if (json['comments'] != null && json['comments'] is List) {
      cCount = (json['comments'] as List).length;
    }

    DateTime date = DateTime.now();
    final dateStr = json['date'] ?? json['created_at'] ?? json['timestamp'];
    if (dateStr != null) {
      date = DateTime.tryParse(dateStr.toString()) ?? DateTime.now();
    }

    final avatarValue = json['avatar_url'] ?? json['avatarUrl'] ?? json['avatarRoute'] ?? json['userAvatar'] ?? 'assets/images/default_avatar.png';

    return ExplorePhoto(
      id: id,
      name: json['name'] ?? json['title'] ?? 'Untitled',
      imageUrl: json['route'] ?? json['url'] ?? json['image_url'] ?? '',
      dateAdded: date,
      likes: likesCount,
      commentsCount: cCount,
      caption: json['caption'] ?? json['description'] ?? '',
      tags: json['tags'] is List ? List<String>.from(json['tags']) : [],
      username: json['owner_username'] ?? json['username'] ?? 'User',
      userAvatar: avatarValue.toString(),
      isOwner: (json['ownerId'] != null && json['ownerId'].toString() == currentUserId?.toString()) || (json['is_owner'] == true),
      allowComments: json['commentAllowed'] ?? json['allow_comments'] ?? true,
      isLiked: isLiked,
      comments: json['comments'] != null && json['comments'] is List
          ? (json['comments'] as List).map((c) => Comment.fromJson(c)).toList()
          : [],
    );
  }
}

class ExploreAlbum {
  final String id;
  final String ownerId;
  final String title;
  final List<String> imageUrls;
  final int photoCount;
  final DateTime createdAt;

  ExploreAlbum({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.imageUrls,
    required this.photoCount,
    required this.createdAt,
  });

  factory ExploreAlbum.fromJson(Map<String, dynamic> json) {
    return ExploreAlbum(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? json['owner_id']?.toString() ?? '',
      title: json['name'] ?? 'Untitled',
      imageUrls: List<String>.from(json['image_urls'] ?? (json['route'] != null ? [json['route']] : [])),
      photoCount: json['photoIds'] != null ? (json['photoIds'] as List).length : 0,
      createdAt: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }
}

List<ExploreAlbum> mockAlbums = [];
