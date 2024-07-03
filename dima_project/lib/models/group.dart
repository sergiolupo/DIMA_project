import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';

class Group {
  final String name;
  final String id;
  String? admin;
  final String? imagePath;
  final String? description;
  final List<String>? categories;
  LastMessage? lastMessage;
  final List<String>? members;
  Group({
    required this.name,
    required this.id,
    this.admin,
    this.imagePath,
    this.description,
    this.categories,
    this.lastMessage,
    this.members,
  });

  static Group fromSnapshot(DocumentSnapshot documentSnapshot) {
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
      members: (documentSnapshot['members'] as List<dynamic>)
          .map((member) => member.toString())
          .toList()
          .cast<String>(),
    );
  }
}
