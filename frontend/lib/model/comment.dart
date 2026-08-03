class Comment {
  int? id;
  int? ownerId;
  int? photoId;
  String? date;
  String text;

  Comment({
    this.id,
    this.ownerId,
    this.photoId,
    this.date,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      ownerId: json['ownerId'],
      photoId: json['photoId'],
      date: json['date']?.toString(),
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ownerId != null) 'ownerId': ownerId,
      if (photoId != null) 'photoId': photoId,
      if (date != null) 'date': date,
      'text': text,
    };
  }
}