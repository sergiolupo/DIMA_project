import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/pages/chats/chat_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/models/message.dart';

import '../mocks/mock_database_service.mocks.dart';

void main() {
  final PrivateChat fakePrivateChat1 = PrivateChat(
    id: '321',
    members: ['user1', 'user2'],
    lastMessage: LastMessage(
      recentMessage: 'Hello',
      recentMessageSender: 'user1',
      recentMessageTimestamp: Timestamp.fromDate(DateTime.now()),
      recentMessageType: Type.text,
      sentByMe: true,
      unreadMessages: 0,
    ),
  );
  final PrivateChat fakePrivateChat2 = PrivateChat(
    id: '432',
    members: ['user1', 'user3'],
    lastMessage: LastMessage(
      recentMessage: 'Hello',
      recentMessageSender: 'user1',
      recentMessageTimestamp: Timestamp.fromDate(DateTime.now()),
      recentMessageType: Type.text,
      sentByMe: true,
      unreadMessages: 0,
    ),
  );
  final Group fakeGroup1 = Group(
    id: '123',
    name: 'Group1',
    isPublic: false,
    members: ['user1', 'user2'],
    imagePath: '',
    lastMessage: LastMessage(
        recentMessage: 'Hello',
        recentMessageSender: 'user1',
        recentMessageTimestamp: Timestamp.fromDate(DateTime.now()),
        recentMessageType: Type.text,
        unreadMessages: 0,
        sentByMe: true),
  );
  final Group fakeGroup2 = Group(
    id: '123',
    name: 'Group2',
    imagePath: '',
    isPublic: false,
    members: ['user1', 'user2'],
    lastMessage: null,
  );
  late final MockDatabaseService mockDatabaseService;
  setUpAll(() {
    mockDatabaseService = MockDatabaseService();
  });
  group('ChatPage Tests', () {
    testWidgets(
        'Displays no chat messages on ChatPage for mobile when no chats and groups exist',
        (WidgetTester tester) async {
      AuthService.setUid('user1');
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([]));
      await tester.pumpWidget(
        CupertinoApp(
          home: ChatPage(
            databaseService: mockDatabaseService,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No groups yet'), findsOneWidget);
      expect(find.text('Create a group to start chatting'), findsOneWidget);
      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();
      expect(find.text('No chats yet'), findsOneWidget);
      expect(find.text('Create a chat to start chatting'), findsOneWidget);
    });
    testWidgets(
        'Displays no chat messages on ChatPage for mobile in dark mode when no chats and groups exist',
        (WidgetTester tester) async {
      AuthService.setUid('user1');
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([]));
      await tester.pumpWidget(
        CupertinoApp(
          home: ChatPage(
            databaseService: mockDatabaseService,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No groups yet'), findsOneWidget);
      expect(find.text('Create a group to start chatting'), findsOneWidget);
      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();
      expect(find.text('No chats yet'), findsOneWidget);
      expect(find.text('Create a chat to start chatting'), findsOneWidget);
    });
    testWidgets(
        'Chat page displays chats and groups for mobile and navigation works',
        (WidgetTester tester) async {
      AuthService.setUid('user1');
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('user2').set({
        'uid': 'user2',
        'name': 'name2',
        'email': 'mail2',
        'imageUrl': '',
        'surname': 'surname2',
        'username': 'username2',
        'requests': [],
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'isPublic': true,
        'token': 'token2',
        'isSignedInWithGoogle': false,
      });
      await firestore.collection('users').doc('user1').set({
        'uid': 'user1',
        'name': 'name1',
        'email': 'mail1',
        'requests': [],
        'imageUrl': '',
        'surname': 'surname1',
        'username': 'username1',
        'isPublic': true,
        'token': 'token1',
        'isSignedInWithGoogle': false,
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
      });
      DocumentSnapshot documentSnapshot2 =
          await firestore.collection('users').doc('user2').get();
      DocumentSnapshot documentSnapshot1 =
          await firestore.collection('users').doc('user1').get();
      when(mockDatabaseService.getPrivateChatsStream()).thenAnswer(
          (_) => Stream.value([fakePrivateChat1, fakePrivateChat2]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([fakeGroup1, fakeGroup2]));
      when(mockDatabaseService.getUserDataFromUID('user2'))
          .thenAnswer((_) => Stream.value(documentSnapshot2));
      when(mockDatabaseService.getUserDataFromUID('user3')).thenAnswer((_) {
        return Stream.error('User not found');
      });
      when(mockDatabaseService.getUserDataFromUID('user1'))
          .thenAnswer((_) => Stream.value(documentSnapshot1));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp(
            home: ChatPage(
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.add_circled_solid));
      await tester.pumpAndSettle();
      expect(find.text('Create'), findsOneWidget); // Create group page
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();
      expect(find.text('Group1'), findsOneWidget); // Chat page
      expect(find.text('Group2'), findsOneWidget);
      expect(find.text('You: '), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Join the conversation!'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), 'AAA');
      await tester.pumpAndSettle();
      expect(find.text('No groups found'), findsOneWidget);
      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();
      expect(find.text('No private chats found'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), '');
      await tester.pumpAndSettle();
      expect(find.text('username2'), findsOneWidget);
      expect(find.text('Deleted Account'), findsOneWidget);
      expect(find.text('You: '), findsNWidgets(2));
      expect(find.text('Hello'), findsNWidgets(2));
    });
  });
}
