import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/storage_service.dart';

class Group {
  final String name;
  final String id;
  final String? admin;
  final Uint8List? imagePath;
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

  static Future<Group> convertToGroup(DocumentSnapshot documentSnapshot) async {
    return Group(
      name: documentSnapshot['groupName'],
      id: documentSnapshot['groupId'],
      admin: documentSnapshot['admin'],
      imagePath: documentSnapshot['groupImage'] == ''
          ? null
          : await StorageService.downloadImageFromStorage(
              documentSnapshot['groupImage'] as String),
      description: documentSnapshot['description'],
      categories: (documentSnapshot['categories'] as List<dynamic>)
          .map((categoryMap) => categoryMap['value'].toString())
          .toList()
          .cast<String>(),
    );
  }
}
