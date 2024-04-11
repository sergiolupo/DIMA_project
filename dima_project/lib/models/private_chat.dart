import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateChat {
  final String user;
  final String visitor;

  PrivateChat({
    required this.visitor,
    required this.user,
  });

  static PrivateChat convertToPrivateChat(DocumentSnapshot documentSnapshot) {
    return PrivateChat(
      user: documentSnapshot['members'][0],
      visitor: documentSnapshot['members'][1],
    );
  }
}
