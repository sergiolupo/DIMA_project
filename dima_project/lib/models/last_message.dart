import 'package:cloud_firestore/cloud_firestore.dart';

class LastMessage {
  final String recentMessage;
  String recentMessageSender;
  final Timestamp recentMessageTimestamp;
  bool? sentByMe;
  LastMessage({
    required this.recentMessage,
    required this.recentMessageSender,
    required this.recentMessageTimestamp,
    this.sentByMe,
  });
}
