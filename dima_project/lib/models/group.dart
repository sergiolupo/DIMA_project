import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';

class Group {
  final String name;
  final String id;
  final String? admin;
  final String? imagePath;
  final String? description;
  final List<String>? categories;
  final LastMessage? lastMessage;

  Group({
    required this.name,
    required this.id,
    this.admin,
    this.imagePath,
    this.description,
    this.categories,
    this.lastMessage,
  });

  static Group convertToGroup(DocumentSnapshot documentSnapshot) {
    return Group(
      name: documentSnapshot['groupName'],
      id: documentSnapshot['groupId'],
      admin: documentSnapshot['admin'],
      imagePath: documentSnapshot['groupImage'],
      description: documentSnapshot['description'],
      categories: (documentSnapshot['categories'] as List<dynamic>)
          .map((categoryMap) => categoryMap['value'].toString())
          .toList()
          .cast<String>(),
      lastMessage: documentSnapshot['recentMessage'] == ""
          ? null
          : LastMessage(
              recentMessage: documentSnapshot['recentMessage'],
              recentMessageSender: documentSnapshot['recentMessageSender'],
              recentMessageTimestamp: documentSnapshot['recentMessageTime'],
            ),
    );
  }
}
