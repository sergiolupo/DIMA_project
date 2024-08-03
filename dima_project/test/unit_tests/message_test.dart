import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/message.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Message class test', () {
    test('Test ReadBy constructor', () {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );
      expect(readBy.username, 'sender');
      expect(readBy.readAt, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
    });
    test('Test Message constructor', () {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );

      Message message = Message(
        id: '123',
        content: 'message',
        sender: 'sender',
        sentByMe: false,
        isGroupMessage: false,
        time: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        chatID: '321',
        readBy: [readBy],
        type: Type.text,
        senderImage: 'image',
      );
      expect(message.id, '123');
      expect(message.content, 'message');
      expect(message.sender, 'sender');
      expect(message.sentByMe, false);
      expect(message.isGroupMessage, false);
      expect(message.time, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(message.readBy, [readBy]);
      expect(message.chatID, '321');
      expect(message.type, Type.text);
      expect(message.senderImage, 'image');
    });
    test('Test Message toMap', () {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );

      Message message = Message(
        id: '123',
        content: 'message',
        sender: 'sender',
        sentByMe: false,
        isGroupMessage: false,
        time: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        chatID: '321',
        readBy: [readBy],
        type: Type.text,
        senderImage: 'image',
      );
      Map<String, dynamic> messageMap = message.toMap();
      expect(messageMap['content'], 'message');
      expect(messageMap['sender'], 'sender');
      expect(messageMap['isGroupMessage'], false);
      expect(messageMap['time'],
          Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(messageMap['readBy'], [readBy.toMap()]);
      expect(messageMap['type'], Type.text.toString());
      expect(messageMap['senderImage'], 'image');
    });
    test('Test Message fromSnapshot', () async {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );

      final firestore = FakeFirebaseFirestore();
      await firestore.collection('messages').doc('123').set({
        'content': 'message',
        'sender': 'sender',
        'isGroupMessage': false,
        'time': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        'readBy': [
          {
            'username': 'sender',
            'readAt': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
          }
        ],
        'type': 'Type.text',
        'senderImage': 'image',
      });
      DocumentSnapshot documentSnapshot =
          await firestore.collection('messages').doc('123').get();
      Message message =
          Message.fromSnapshot(documentSnapshot, '321', 'currentUsername');
      expect(message.id, '123');
      expect(message.content, 'message');
      expect(message.sender, 'sender');
      expect(message.sentByMe, false);
      expect(message.isGroupMessage, false);
      expect(message.time, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(message.readBy, [readBy]);
      expect(message.chatID, '321');
      expect(message.type, Type.text);
      expect(message.senderImage, 'image');
    });
  });
}
