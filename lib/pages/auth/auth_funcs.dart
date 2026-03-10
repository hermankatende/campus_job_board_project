import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static Future<void> saveUser(String name, String email, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
      });
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }
}
