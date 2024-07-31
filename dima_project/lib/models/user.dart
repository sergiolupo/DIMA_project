import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String email;
  final String? password;
  final String name;
  final String surname;
  final String username;
  final List<String> categories;
  final String? imagePath;
  final String? uid;
  bool? isPublic;
  List<String>? requests;
  String? token;
  UserData({
    required this.categories,
    this.imagePath,
    required this.email,
    this.password,
    required this.name,
    required this.surname,
    required this.username,
    this.uid,
    this.isPublic,
    this.requests,
    this.token,
  });

  static UserData fromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserData(
      name: documentSnapshot['name'],
      surname: documentSnapshot['surname'],
      username: documentSnapshot['username'],
      email: documentSnapshot['email'],
      imagePath: documentSnapshot['imageUrl'],
      categories: (documentSnapshot['selectedCategories'] as List<dynamic>)
          .map((categoryMap) => categoryMap['value'].toString())
          .toList()
          .cast<String>(),
      uid: documentSnapshot.id,
      isPublic: documentSnapshot['isPublic'],
      requests: (documentSnapshot['requests'] as List<dynamic>)
          .map((request) => request.toString())
          .toList()
          .cast<String>(),
      token: documentSnapshot['token'],
    );
  }

  static UserData fromMap(Map<String, dynamic> json) {
    return UserData(
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      email: json['email'],
      imagePath: json['imagePath'],
      categories: List<String>.from(json['categories']),
      uid: json['uid'],
      isPublic: json['isPublic'],
      requests: List<String>.from(json['requests']),
      token: json['token'],
    );
  }
}
