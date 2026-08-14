class User {
  int? id;
  String username;
  String? displayName;
  String? password;
  List<int> photoIds;
  List<int> albumIds;
  List<int> likedPhotoIds;
  bool isBanned;
  bool isLoggedIn;
  int commentCount;
  String rank;
  String? enterType;

  User({
    this.id,
    required this.username,
    this.displayName,
    this.password,
    List<int>? photoIds,
    List<int>? albumIds,
    List<int>? likedPhotoIds,
    this.isBanned = false,
    this.isLoggedIn = false,
    this.commentCount = 0,
    this.rank = 'NEWBIE',
    this.enterType,
  })  : photoIds = photoIds ?? [],
        albumIds = albumIds ?? [],
        likedPhotoIds = likedPhotoIds ?? [];

  bool get isAdmin => rank == 'ADMIN';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['display_name'] ?? json['username'] ?? '',
      password: json['password'],
      photoIds: json['photoIds'] != null
          ? List<int>.from(json['photoIds'])
          : [],
      albumIds: json['albumIds'] != null
          ? List<int>.from(json['albumIds'])
          : [],
      likedPhotoIds: json['likedPhotoIds'] != null
          ? List<int>.from(json['likedPhotoIds'])
          : [],
      isBanned: json['isBanned'] ?? false,
      isLoggedIn: json['isLoggedIn'] ?? false,
      commentCount: json['commentCount'] ?? 0,
      rank: json['rank'] ?? 'NEWBIE',
      enterType: json['enterType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      if (displayName != null) 'displayName': displayName,
      if (password != null) 'password': password,
      'photoIds': photoIds,
      'albumIds': albumIds,
      'likedPhotoIds': likedPhotoIds,
      'isBanned': isBanned,
      'isLoggedIn': isLoggedIn,
      'commentCount': commentCount,
      'rank': rank,
      if (enterType != null) 'enterType': enterType,
    };
  }
}