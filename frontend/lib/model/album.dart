class Album {
  int? id;
  int? ownerId;
  String name;
  String? date;
  List<int> photoIds;

  Album({
    this.id,
    this.ownerId,
    required this.name,
    this.date,
    List<int>? photoIds,
  }) : photoIds = photoIds ?? [];

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'] ?? '',
      date: json['date']?.toString(),
      photoIds: json['photoIds'] != null
          ? List<int>.from(json['photoIds'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      'name': name,
      if (date != null) 'date': date,
      'photoIds': photoIds,
    };
  }
}