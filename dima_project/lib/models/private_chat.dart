import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';

class PrivateChat {
  final String user;
  final String visitor;
  final LastMessage? lastMessage;
  final String? id;
  PrivateChat({
    required this.visitor,
    required this.user,
    this.lastMessage,
    this.id,
  });

  static PrivateChat convertToPrivateChat(
      DocumentSnapshot documentSnapshot, String username) {
    return PrivateChat(
      user: documentSnapshot['members'][0] == username
          ? documentSnapshot['members'][1]
          : documentSnapshot['members'][0],
      visitor: username,
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
