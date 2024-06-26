import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';

class PrivateChat {
  final List<String> members;
  final LastMessage? lastMessage;
  String? id;
  PrivateChat({
    required this.members,
    this.lastMessage,
    this.id,
  });

  static PrivateChat fromSnapshot(DocumentSnapshot documentSnapshot) {
    return PrivateChat(
      members: documentSnapshot['members'].cast<String>(),
      lastMessage: documentSnapshot['recentMessage'] == ""
          ? null
          : LastMessage(
              recentMessage: documentSnapshot['recentMessage'],
              recentMessageSender: documentSnapshot['recentMessageSender'],
              recentMessageTimestamp: documentSnapshot['recentMessageTime'],
            ),
      id: documentSnapshot.id,
    );
  }
}
