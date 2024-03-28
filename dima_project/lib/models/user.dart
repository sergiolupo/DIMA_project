import 'dart:typed_data';

class UserData {
  final String email;
  final String password;
  final String name;
  final String surname;
  final String username;
  List<dynamic> categories;
  Uint8List imagePath;
  UserData({
    required this.categories,
    required this.imagePath,
    required this.email,
    required this.password,
    required this.name,
    required this.surname,
    required this.username,
  });
}
