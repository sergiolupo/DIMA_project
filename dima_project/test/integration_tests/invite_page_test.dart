import 'package:dima_project/pages/invite_page.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';
/*
void main() {
  late final MockDatabaseService mockDatabaseService;
  setUp(
    () {
      mockDatabaseService = MockDatabaseService();
    },
  );
  testWidgets('InvitePage displays correctly', (WidgetTester tester) async {
    when(mockDatabaseService.checkIfJoined(any, any, any))
        .thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          followerProvider.overrideWith(
            (ref, uid) => Future.value([
              UserData(
                uid: 'uid',
                username: 'username',
                name: 'name',
                surname: 'surname',
                imagePath: '',
                email: 'email',
                categories: ['category'],
              ),
            ]),
          ),
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
        ],
        child: CupertinoApp(
          home: InvitePage(
            invitePageKey: (String uid) {},
            invitedUsers: const [],
            isGroup: false,
            id: 'id',
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(find.byType(InvitationTile), findsOneWidget);
    expect(find.text('username'), findsOneWidget);
  });

  testWidgets(
      'InvitePage displays no followers message when there are no followers',
      (WidgetTester tester) async {
    final container = ProviderContainer(overrides: [
      followerProvider('some_uid').overrideWithValue(const AsyncValue.data([])),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        child: CupertinoApp(
          home: InvitePage(
            invitePageKey: (String uid) {},
            invitedUsers: [],
            isGroup: false,
            id: 'groupId',
          ),
        ),
      ),
    );

    expect(find.text('No followers'), findsOneWidget);
  });

  testWidgets('InvitePage displays filtered users based on search input',
      (WidgetTester tester) async {
    final mockUser = UserData(
        uid: '1',
        username: 'testuser',
        name: 'Test',
        surname: 'User',
        imagePath: 'test.png');

    final container = ProviderContainer(overrides: [
      followerProvider('some_uid')
          .overrideWithValue(AsyncValue.data([mockUser])),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        container: container,
        child: CupertinoApp(
          home: InvitePage(
            invitePageKey: (String uid) {},
            invitedUsers: [],
            isGroup: false,
            id: 'groupId',
          ),
        ),
      ),
    );

    // Ensure that the user is displayed initially
    expect(find.text('testuser'), findsOneWidget);

    // Simulate entering text in the search field
    await tester.enterText(
        find.byType(CupertinoSearchTextField), 'nonexistent');
    await tester.pump();

    // Ensure that no results are shown for non-existent search
    expect(find.text('Not results found'), findsOneWidget);
  });

  testWidgets('InviteTile can be tapped to navigate to user profile',
      (WidgetTester tester) async {
    final mockUser = UserData(
        uid: '1',
        username: 'testuser',
        name: 'Test',
        surname: 'User',
        imagePath: 'test.png');

    // Mock the invitePageKey callback
    final invitePageKeyMock = (String uid) {};

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: InvitePage(
            invitePageKey: invitePageKeyMock,
            invitedUsers: [],
            isGroup: false,
            id: 'groupId',
          ),
        ),
      ),
    );

    // Find and tap the user tile
    await tester.tap(find.text('testuser'));
    await tester.pumpAndSettle();

    // Check if the correct navigation occurred (you will need to adjust this based on how navigation is implemented)
    expect(find.byType(UserProfile), findsOneWidget);
  });

  testWidgets('InvitationTile toggles invite state when tapped',
      (WidgetTester tester) async {
    final mockUser = UserData(
        uid: '1',
        username: 'testuser',
        name: 'Test',
        surname: 'User',
        imagePath: 'test.png');

    // Mock the invitePageKey callback
    bool invitedState = false;
    final invitePageKeyMock = (String uid) {
      invitedState = !invitedState;
    };

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: InvitationTile(
            user: mockUser,
            invitePageKey: invitePageKeyMock,
            invited: invitedState,
            isJoining: false,
          ),
        ),
      ),
    );

    expect(find.text('Invite'), findsOneWidget);

    // Tap the invite button
    await tester.tap(find.text('Invite'));
    await tester.pump();

    expect(find.text('Invited'), findsOneWidget);
    expect(invitedState, true);
  });
}
*/