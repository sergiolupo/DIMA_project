import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ReadBy {
  final String username;
  final int readAt;

  ReadBy({
    required this.username,
    required this.readAt,
  });

  toMap() {
    return {
      'username': username,
      'readAt': readAt,
    };
  }
}

class Message {
  final String? id;
  final String content;
  final String sender;
  final String? receiver;
  final bool? sentByMe;
  final String senderImage;
  final bool isGroupMessage;
  final Timestamp time;
  final List<ReadBy>? readBy;
  final String? chatID;
  Message({
    required this.content,
    required this.sender,
    this.sentByMe,
    required this.senderImage,
    required this.isGroupMessage,
    required this.time,
    this.receiver,
    this.id,
    this.chatID,
    this.readBy,
  });

  toMap() {
    return {
      'content': content,
      'sender': sender,
      'senderImage': senderImage,
      'isGroupMessage': isGroupMessage,
      'time': time,
      'readBy': readBy!.map((readBy) => readBy.toMap()).toList(),
    };
  }

  fromSnapshot(DocumentSnapshot snapshot) {
    debugPrint('snapshot: $snapshot["readBy"]');

    return Message(
      content: snapshot['content'],
      sender: snapshot['sender'],
      sentByMe: snapshot['sentByMe'],
      senderImage: snapshot['senderImage'],
      isGroupMessage: snapshot['isGroupMessage'],
      time: snapshot['time'],
      id: snapshot.id,
      readBy: (snapshot['readBy'] as List<dynamic>)
          .map((readBy) => ReadBy(
                username: readBy['username'],
                readAt: readBy['readAt'],
              ))
          .toList()
          .cast<ReadBy>(),
    );
  }
}
