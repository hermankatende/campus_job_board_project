// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'chat.dart'; // Adjust this import as per your project structure

// class ConversationList extends StatefulWidget {
//   @override
//   _ConversationListState createState() => _ConversationListState();
// }

// class _ConversationListState extends State<ConversationList> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late String posterId;

//   @override
//   void initState() {
//     super.initState();
//     posterId = _auth.currentUser!.uid;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Conversations'),
//       ),
//       body: StreamBuilder(
//         stream: _firestore
//             .collection('messages')
//             .where('posterId', isEqualTo: posterId)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No conversations found'));
//           }

//           var conversations = <String, Map<String, String>>{};
//           for (var doc in snapshot.data!.docs) {
//             var data = doc.data() as Map<String, dynamic>;
//             var receiverId = data['receiverId'] ?? '';
//             var jobId = data['jobId'] ?? '';
//             var jobTitle = data['jobTitle'] ?? '';

//             if (receiverId.isNotEmpty &&
//                 jobId.isNotEmpty &&
//                 jobTitle.isNotEmpty) {
//               conversations[receiverId] = {
//                 'jobId': jobId,
//                 'jobTitle': jobTitle,
//               };
//             }
//           }

//           if (conversations.isEmpty) {
//             return Center(child: Text('No conversations found'));
//           }

//           return ListView.builder(
//             itemCount: conversations.length,
//             itemBuilder: (context, index) {
//               var receiverId = conversations.keys.elementAt(index);
//               var jobId = conversations[receiverId]!['jobId']!;
//               var jobTitle = conversations[receiverId]!['jobTitle']!;
//               return ListTile(
//                 title: Text(jobTitle),
//                 subtitle: Text('Applicant: $receiverId'),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChatScreen(
//                         jobId: jobId,
//                         posterId: posterId,
//                         receiverId: receiverId,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cjb/pages/main/main_page/employer/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'chat_screen.dart'; // Import the ChatScreen widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId;

  ChatListScreen({required this.currentUserId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return Center(child: Text('No active chats'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chatData = chats[index].data() as Map<String, dynamic>;
              var otherUserId = chatData['participants']
                  .firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(title: Text('Loading...'));
                  }

                  var otherUserData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(otherUserData['name']),
                    subtitle: Text(chatData['lastMessage']),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          senderId: currentUserId,
                          receiverId: otherUserId,
                          jobTitle: chatData['jobTitle'] ?? 'No Title',
                          employeeName: otherUserData['name'] ?? 'Unknown User',
                        ),
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
