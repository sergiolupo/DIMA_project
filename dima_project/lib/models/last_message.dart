import 'package:cloud_firestore/cloud_firestore.dart';

class LastMessage {
  final String recentMessage;
  final String recentMessageSender;
  final Timestamp recentMessageTimestamp;
  LastMessage({
    required this.recentMessage,
    required this.recentMessageSender,
    required this.recentMessageTimestamp,
  });
}
