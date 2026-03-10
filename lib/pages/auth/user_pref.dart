import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String id;
  final String imagePath;
  User({required this.id, required this.imagePath});

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      imagePath: data['image_path'] ?? 'defaultImagePath',
    );
  }
}

class UserPreferences {
  static User? myUser;

  static Future<void> initialize() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          myUser = User.fromFirestore(userDoc);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }
}
