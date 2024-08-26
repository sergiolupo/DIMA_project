import 'package:dima_project/pages/invite_user_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/user_invitation_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';

import '../mocks/mock_database_service.mocks.dart';

void main() {
  late final DatabaseService mockDatabaseService = MockDatabaseService();

  final testUsers = [
    UserData(
        uid: '1',
        username: 'test_user1',
        name: 'Test1',
        surname: 'User1',
        imagePath: '',
        categories: [],
        email: ''),
    UserData(
        uid: '2',
        username: 'test_user2',
        name: 'Test2',
        surname: 'User2',
        imagePath: '',
        categories: [],
        email: ''),
  ];

  testWidgets('InvitePage interaction and search functionality',
      (WidgetTester tester) async {
    AuthService.setUid('test');
    List<String> users = [];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          followerProvider.overrideWith(
            (ref, uid) => Future.value(testUsers),
          ),
        ],
        child: CupertinoApp(
          home: InviteUserPage(
            invitePageKey: (String key) {
              users.add(key);
            },
            invitedUsers: users,
            isGroup: false,
            id: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Search followers...'), findsOneWidget);
    expect(find.byType(UserInvitationTile), findsNWidgets(2));

    await tester.enterText(find.byType(CupertinoSearchTextField), 'hhhh');
    await tester.pumpAndSettle();
    expect(find.text('No followers found'), findsOneWidget);

    await tester.enterText(find.byType(CupertinoSearchTextField), 'test_user1');
    await tester.pumpAndSettle();
    expect(find.text("Invite"), findsOneWidget);
    expect(find.text("test_user1"), findsNWidgets(2));

    //await tester.tap(find.byKey(const Key('invite_button')));
    await tester.tap(find.text("Invite"));
    await tester.pumpAndSettle();

    expect(find.text("Invited"), findsOneWidget);
  });
}
