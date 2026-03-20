class PostEntity {
  final String? username;
  final String? description;
  final String? imageUrl;
  final String? email;
  final DateTime? timestamp;

  PostEntity({
    this.username,
    this.description,
    this.imageUrl,
    this.email,
    this.timestamp,
  });

  factory PostEntity.fromJson(Map<String, dynamic> data) {
    return PostEntity(
      username: data['username'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      email: data['email'] as String? ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'].toString())
          : null,
    );
  }
}
