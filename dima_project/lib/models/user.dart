import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String email;
  final String? password;
  final String name;
  final String surname;
  final String username;
  final List<String> categories;
  final String? imagePath;
  UserData({
    required this.categories,
    this.imagePath,
    required this.email,
    this.password,
    required this.name,
    required this.surname,
    required this.username,
  });

  static UserData convertToUserData(DocumentSnapshot documentSnapshot) {
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
    );
  }
}
