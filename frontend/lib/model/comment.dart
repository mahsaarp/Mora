class Comment {
  int? id;
  int? ownerId;
  int? photoId;
  String? date;
  String text;
  String? username;
  String? avatarRoute;

  Comment({
    this.id,
    this.ownerId,
    this.photoId,
    this.date,
    required this.text,
    this.username,
    this.avatarRoute,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      ownerId: json['ownerId'],
      photoId: json['photoId'],
      date: json['date']?.toString(),
      text: json['text'] ?? '',
      username: json['username'] ?? json['owner_username'],
      avatarRoute: json['avatarRoute'] ?? json['avatar_route'] ?? json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      if (photoId != null) 'photoId': photoId,
      if (date != null) 'date': date,
      'text': text,
      if (username != null) 'username': username,
      if (avatarRoute != null) 'avatarRoute': avatarRoute,
    };
  }
}