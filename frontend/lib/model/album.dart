class Album {
  int? id;
  int? ownerId;
  String name;
  String? date;
  List<int> photoIds;
  List<String> imageUrls;

  String get title => name;
  int get photoCount => photoIds.length;

  Album({
    this.id,
    this.ownerId,
    required this.name,
    this.date,
    List<int>? photoIds,
    List<String>? imageUrls,
  }) : photoIds = photoIds ?? [],
        imageUrls = imageUrls ?? [];

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      ownerId: json['ownerId'] ?? json['owner_id'],
      name: json['name'] ?? json['title'] ?? '',
      date: json['date']?.toString() ?? json['created_at']?.toString(),
      photoIds: json['photoIds'] != null
          ? List<int>.from(json['photoIds'])
          : (json['photo_ids'] != null ? List<int>.from(json['photo_ids']) : []),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : (json['image_urls'] != null ? List<String>.from(json['image_urls']) : []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      'name': name,
      if (date != null) 'date': date,
      'photoIds': photoIds,
      'imageUrls': imageUrls,
    };
  }
}