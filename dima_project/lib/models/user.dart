import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/storage_service.dart';

class UserData {
  final String email;
  final String? password;
  final String name;
  final String surname;
  final String username;
  final List<String> categories;
  final Uint8List? imagePath;
  UserData({
    required this.categories,
    required this.imagePath,
    required this.email,
    this.password,
    required this.name,
    required this.surname,
    required this.username,
  });

  static Future<UserData> convertToUserData(
      DocumentSnapshot documentSnapshot) async {
    return UserData(
      name: documentSnapshot['name'],
      surname: documentSnapshot['surname'],
      username: documentSnapshot['username'],
      email: documentSnapshot['email'],
      password: '',
      imagePath: documentSnapshot['imageUrl'] == ''
          ? null
          : await StorageService.downloadImageFromStorage(
              documentSnapshot['imageUrl']),
      categories: (documentSnapshot['selectedCategories'] as List<dynamic>)
          .map((categoryMap) => categoryMap['value'].toString())
          .toList()
          .cast<String>(),
    );
  }
}
