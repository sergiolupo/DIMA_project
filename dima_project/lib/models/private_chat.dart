import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateChat {
  final String user;
  final String visitor;

  PrivateChat({
    required this.visitor,
    required this.user,
  });

  static PrivateChat convertToPrivateChat(
      DocumentSnapshot documentSnapshot, String username) {
    documentSnapshot['members'].remove(username);
    return PrivateChat(
      user: documentSnapshot['members'][0],
      visitor: username,
    );
  }
}
