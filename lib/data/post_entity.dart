import 'package:cloud_firestore/cloud_firestore.dart';

class PostEntity {
  final String? username;
  final String? description;
  final String? imageUrl;
  final String? email;
  final Timestamp? timestamp;

  PostEntity({
    this.username,
    this.description,
    this.imageUrl,
    this.email,
    this.timestamp,
  });

  factory PostEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostEntity(
      username: data['username'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      email: data['email'] as String? ?? '',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }
}
