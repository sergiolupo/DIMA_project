import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/pages/chats/chat_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/models/message.dart';
import 'package:path_provider/path_provider.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_image_picker.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

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
    members: ['user1', 'user2,user3'],
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

  List<ReadBy> readBy = [
    ReadBy(
      username: 'user1',
      readAt: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
    ),
    ReadBy(
      username: 'user2',
      readAt: Timestamp.fromDate(DateTime(2024, 2, 3, 1, 1)),
    ),
  ];
  List<Message> messages = [
    Message(
      content: 'Hello',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.text,
    ),
    Message(
      content: 'Title\nDescription\nhttps://example.com\nhttps://imageurl.com',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.news,
    ),
    Message(
      content: 'image_url',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.image,
    ),
    Message(
      content: 'event_id',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.event,
    )
  ];

  late final MockDatabaseService mockDatabaseService;
  late final MockNotificationService mockNotificationService;
  late final MockImagePicker mockImagePicker;

  setUpAll(() {
    mockDatabaseService = MockDatabaseService();
    mockNotificationService = MockNotificationService();
    mockImagePicker = MockImagePicker();
  });

  group('ChatPage Tests for mobile', () {
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
            notificationService: mockNotificationService,
            imagePicker: mockImagePicker,
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
            notificationService: mockNotificationService,
            imagePicker: mockImagePicker,
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
              notificationService: mockNotificationService,
              imagePicker: mockImagePicker,
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
  group('Create Group Page Tests', () {
    testWidgets(
        "CreateGroup page displays correctly and successfully creates a new group for mobile",
        (WidgetTester tester) async {
      AuthService.setUid('user1');

      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.createGroup(any, any, any)).thenAnswer(
        (_) => Future.value(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: ChatPage(
              databaseService: mockDatabaseService,
              notificationService: mockNotificationService,
              imagePicker: mockImagePicker,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.add_circled_solid));
      await tester.pumpAndSettle();
      expect(find.text('Create'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField).first, 'Group3');
      await tester.enterText(
          find.byType(CupertinoTextField).at(1), 'Description');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.clear_circled_solid));
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Event description is required'), findsOneWidget);
      expect(find.text('Validation Error'), findsOneWidget);
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoTextField).at(1), 'Description');
      await tester.tap(find.text('Categories')); // Categories Page
      await tester.pumpAndSettle();
      expect(find.text('Categories Selection'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Members')); // Invite Page
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      /*await tester.tap(find.byType(Image));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget); //Image Crop Page
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();*/

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('No groups yet'), findsOneWidget); // Chat Page
      expect(find.text('Create a group to start chatting'), findsOneWidget);
    });
  });
  group('Test chat functionality', () {
    tearDown(() async {
      // List of files to delete
      final files = ['doc1.png', 'doc2.png'];

      // Delete each file if it exists
      for (final fileName in files) {
        final file = File(fileName);
        if (await file.exists()) {
          await file.delete();
          debugPrint('$fileName deleted.');
        }
      }
    });

    testWidgets(
        "Group chat page renders correctly and send message functionality works correctly",
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
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([fakePrivateChat1]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([fakeGroup1]));
      when(mockNotificationService.sendNotificationOnGroup(any, any))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.getUserDataFromUID('user1'))
          .thenAnswer((_) => Stream.value(documentSnapshot1));
      when(mockDatabaseService.getUserDataFromUID('user2'))
          .thenAnswer((_) => Stream.value(documentSnapshot2));
      when(mockDatabaseService.getUserDataFromUID('user3')).thenAnswer((_) {
        return Stream.error('User not found');
      });
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          return;
        },
      );
      when(mockDatabaseService.sendMessage(any, any))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.getChats(any)).thenAnswer((_) {
        return Stream.value(messages);
      });
      when(mockDatabaseService.getChats(any)).thenAnswer((_) {
        return Stream.value(messages);
      });
      when(mockImagePicker.pickImage(
              source: ImageSource.camera, imageQuality: 80))
          .thenAnswer((_) async {
        final ByteData data = await rootBundle.load('assets/logo.png');
        final Uint8List bytes = data.buffer.asUint8List();
        Directory tempDir = await getTemporaryDirectory();
        final File file = await File(
          '${tempDir.path}/doc1.png',
        ).writeAsBytes(bytes);

        return XFile(file.path);
      });
      when(mockImagePicker.pickMultiImage(imageQuality: 80)).thenAnswer(
        (_) async {
          final ByteData data = await rootBundle.load('assets/logo.png');
          final Uint8List bytes = data.buffer.asUint8List();
          Directory tempDir = await getTemporaryDirectory();
          final File file = await File(
            '${tempDir.path}/doc2.png',
          ).writeAsBytes(bytes);
          return [XFile(file.path)];
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventProvider.overrideWith(
              (ref, eventId) async => Event(
                id: 'event_id',
                name: 'Sample Event',
                description: 'Event Description',
                imagePath: '',
                admin: 'user1',
                isPublic: true,
              ),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: ChatPage(
              databaseService: mockDatabaseService,
              notificationService: mockNotificationService,
              imagePicker: mockImagePicker,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Group1'));
      await tester.pumpAndSettle();
      expect(find.text('Group1'), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();
      expect(find.text('Group1'), findsOneWidget);
      expect(find.text('You: '), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      await tester.tap(find.text('Group1'));
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Hello'));
      await tester.pumpAndSettle();
      expect(find.text('Copy Text'), findsOneWidget);
      expect(find.text('Delete Message'), findsOneWidget);
      expect(find.text('Read By'), findsOneWidget);
      await tester.tap(find.text('Copy Text'));
      await tester.pumpAndSettle();
      expect(find.text('Copied to clipboard'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField), 'Hello');
      await tester.tap(find.byIcon(LineAwesomeIcons.paper_plane));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.photo_fill));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.camera_fill).last);
      await tester.pumpAndSettle();
      //await tester.tap(find.byIcon(CupertinoIcons.calendar));
    });
  });
}
