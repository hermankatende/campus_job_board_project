import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cjb/data/post_entity.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PostEntity> _cachedPosts = [];

  Future<List<PostEntity>> fetchPosts() async {
    if (_cachedPosts.isNotEmpty) {
      return _cachedPosts; // Return cached posts
    }

    try {
      final snapshot = await _firestore.collection('posts').get();
      _cachedPosts =
          snapshot.docs.map((doc) => PostEntity.fromFirestore(doc)).toList();
      return _cachedPosts;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error (${e.code}): ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }
}
