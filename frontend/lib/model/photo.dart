class Photo {
  int? id;
  int? ownerId;
  String name;
  String? date;
  List<String> tags;
  String? caption;
  List<int> userLikedIds;
  bool commentAllowed;
  List<int> albumIds;
  List<int> commentIds;
  String? route;
  String? base64Data;

  Photo({
    this.id,
    this.ownerId,
    required this.name,
    this.date,
    List<String>? tags,
    this.caption,
    List<int>? userLikedIds,
    this.commentAllowed = true,
    List<int>? albumIds,
    List<int>? commentIds,
    this.route,
    this.base64Data,
  })  : tags = tags ?? [],
        userLikedIds = userLikedIds ?? [],
        albumIds = albumIds ?? [],
        commentIds = commentIds ?? [];

  int get likesCount => userLikedIds.length;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'] ?? '',
      date: json['date']?.toString(),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      caption: json['caption'],
      userLikedIds: json['userLikedIds'] != null
          ? List<int>.from(json['userLikedIds'])
          : [],
      commentAllowed: json['commentAllowed'] ?? true,
      albumIds: json['albumIds'] != null
          ? List<int>.from(json['albumIds'])
          : [],
      commentIds: json['commentIds'] != null
          ? List<int>.from(json['commentIds'])
          : [],
      route: json['route'],
      base64Data: json['base64Data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      'name': name,
      if (date != null) 'date': date,
      'tags': tags,
      if (caption != null) 'caption': caption,
      'userLikedIds': userLikedIds,
      'commentAllowed': commentAllowed,
      'albumIds': albumIds,
      'commentIds': commentIds,
      if (route != null) 'route': route,
      if (base64Data != null) 'base64Data': base64Data,
    };
  }
}