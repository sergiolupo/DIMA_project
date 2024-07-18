import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String email;
  final String? password;
  final String name;
  final String surname;
  final String username;
  final List<String> categories;
  final String? imagePath;
  final bool? online;
  final Timestamp? lastSeen;
  final bool? isTyping;
  final String? typingTo;
  final String? uuid;
  bool? isPublic;
  List<String>? requests;
  UserData({
    required this.categories,
    this.imagePath,
    required this.email,
    this.password,
    required this.name,
    required this.surname,
    required this.username,
    this.online,
    this.lastSeen,
    this.isTyping,
    this.typingTo,
    this.uuid,
    this.isPublic,
    this.requests,
  });

  static UserData fromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserData(
      name: documentSnapshot['name'],
      surname: documentSnapshot['surname'],
      username: documentSnapshot['username'],
      email: documentSnapshot['email'],
      password: '',
      imagePath: documentSnapshot['imageUrl'],
      categories: (documentSnapshot['selectedCategories'] as List<dynamic>)
          .map((categoryMap) => categoryMap['value'].toString())
          .toList()
          .cast<String>(),
      online: documentSnapshot['isOnline'],
      lastSeen: documentSnapshot['lastSeen'],
      isTyping: documentSnapshot['isTyping'],
      typingTo: documentSnapshot['typingTo'],
      uuid: documentSnapshot.id,
      isPublic: documentSnapshot['isPublic'],
      requests: (documentSnapshot['requests'] as List<dynamic>)
          .map((request) => request.toString())
          .toList()
          .cast<String>(),
    );
  }
}
