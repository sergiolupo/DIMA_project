import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String name;
  final String id;
  final String? admin;
  final String? imagePath;
  final String? description;
  final List<String>? categories;
  Group({
    required this.name,
    required this.id,
    this.admin,
    this.imagePath,
    this.description,
    this.categories,
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
    );
  }
}
