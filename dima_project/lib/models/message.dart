import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String sender;
  final String? receiver;
  final bool? sentByMe;
  final String senderImage;
  final bool isGroupMessage;
  final Timestamp time;
  Message({
    required this.content,
    required this.sender,
    this.sentByMe,
    required this.senderImage,
    required this.isGroupMessage,
    required this.time,
    this.receiver,
  });
  toMap() {
    return {
      'content': content,
      'sender': sender,
      'senderImage': senderImage,
      'isGroupMessage': isGroupMessage,
      'time': time,
    };
  }
}
