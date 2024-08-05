import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/widgets/chats/private_chat_tile_tablet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';

void main() {
  testWidgets('PrivateChatTileTablet displays username and last message',
      (WidgetTester tester) async {
    final privateChat = PrivateChat(
        id: "1",
        members: ['uid1', 'uid2'],
        lastMessage: LastMessage(
          recentMessage: "Hello!",
          recentMessageType: Type.text,
          recentMessageTimestamp: Timestamp.fromDate(
            DateTime(2024, 8, 5, 1, 1),
          ),
          unreadMessages: 1,
          sentByMe: false,
          recentMessageSender: 'user',
        ));

    final user = UserData(
      username: 'user',
      imagePath: '',
      categories: ["category"],
      name: 'name',
      surname: 'surname',
      email: 'email',
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1200, 700)),
        child: CupertinoApp(
          home: CupertinoPageScaffold(
            child: PrivateChatTileTablet(
              privateChat: privateChat,
              onPressed: (chat) {},
              other: user,
              onDismissed: (direction) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('user'), findsOneWidget);
    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text("1"), findsOneWidget); // Check for unread message badge
  });

  testWidgets(
      'PrivateChatTileTablet displays correct icon for event message type',
      (WidgetTester tester) async {
    // Arrange
    final privateChatEvent = PrivateChat(
      id: "1",
      members: ['uid1', 'uid2'],
      lastMessage: LastMessage(
        sentByMe: false,
        recentMessage: 'Event',
        recentMessageType: Type.event,
        recentMessageTimestamp: Timestamp.now(),
        unreadMessages: 0,
        recentMessageSender: 'user',
      ),
    );

    final user = UserData(
      username: 'user',
      imagePath: '',
      categories: ["category"],
      name: 'name',
      surname: 'surname',
      email: 'email',
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1200, 700)),
        child: CupertinoApp(
          home: CupertinoPageScaffold(
            child: PrivateChatTileTablet(
              privateChat: privateChatEvent,
              onPressed: (chat) {},
              other: user,
              onDismissed: (direction) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(CupertinoIcons.calendar), findsOneWidget);
  });

  testWidgets('PrivateChatTileTablet handles dismiss action',
      (WidgetTester tester) async {
    final privateChat = PrivateChat(
      id: "1",
      members: ['uid1', 'uid2'],
      lastMessage: LastMessage(
        sentByMe: false,
        recentMessage: 'Hi!',
        recentMessageType: Type.text,
        recentMessageTimestamp: Timestamp.now(),
        unreadMessages: 0,
        recentMessageSender: 'user',
      ),
    );

    final user = UserData(
      username: 'user',
      imagePath: '',
      categories: ["category"],
      name: 'name',
      surname: 'surname',
      email: 'email',
    );

    bool isDismissed = false;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1200, 700)),
        child: CupertinoApp(
          home: CupertinoPageScaffold(
            child: PrivateChatTileTablet(
              privateChat: privateChat,
              onPressed: (chat) {},
              other: user,
              onDismissed: (direction) {
                isDismissed = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(Dismissible), const Offset(-300, 0));

    await tester.pumpAndSettle();

    expect(isDismissed, isTrue);
  });
}
