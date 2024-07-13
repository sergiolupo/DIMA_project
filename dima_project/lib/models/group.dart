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
  final bool isPublic;
  final List<String>? requests;
  final bool notify;
  Group({
    required this.name,
    required this.id,
    this.admin,
    this.imagePath,
    this.description,
    this.categories,
    this.lastMessage,
    this.members,
    required this.isPublic,
    this.requests,
    required this.notify,
  });

  static Map<String, dynamic> toMap(Group group) {
    return {
      'groupId': group.id,
      'groupName': group.name,
      'admin': group.admin ?? "",
      'groupImage': group.imagePath ?? "",
      'description': group.description ?? "",
      'categories':
          group.categories?.map((category) => {'value': category}).toList(),
      'members': group.members ?? [],
      'isPublic': group.isPublic,
      'requests': group.requests ?? [],
      'notify': group.notify,
    };
  }

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
      isPublic: documentSnapshot['isPublic'],
      requests: (documentSnapshot['requests'] as List<dynamic>)
          .map((request) => request.toString())
          .toList()
          .cast<String>(),
      notify: documentSnapshot['notify'],
    );
  }
}
