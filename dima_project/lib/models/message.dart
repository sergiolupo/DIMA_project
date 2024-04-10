import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String sender;
  final bool? sentByMe;
  final Uint8List? imagePath;
  final bool isGroupMessage;
  final Timestamp time;
  Message({
    required this.content,
    required this.sender,
    this.sentByMe,
    this.imagePath,
    required this.isGroupMessage,
    required this.time,
  });
  toMap() {
    return {
      'content': content,
      'sender': sender,
      'imagePath': imagePath,
      'isGroupMessage': isGroupMessage,
      'time': time,
    };
  }
}
