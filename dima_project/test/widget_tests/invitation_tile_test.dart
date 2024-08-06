import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/invitation_tile.dart';

void main() {
  final user = UserData(
    uid: '123',
    username: 'test_user',
    name: 'Test',
    surname: 'User',
    imagePath: '',
    categories: ['category'],
    email: 'email',
  );

  group('InvitationTile Tests', () {
    testWidgets('InvitationTile renders correctly when invited is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: InvitationTile(
            user: user,
            invitePageKey: (uid) {},
            invited: false,
            isJoining: false,
          ),
        ),
      );

      expect(find.text('test_user'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Invite'), findsOneWidget);
    });

    testWidgets(
        'InvitationTile invites the user when the invite button is tapped',
        (WidgetTester tester) async {
      bool wasInvited = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: InvitationTile(
            user: user,
            invitePageKey: (uid) {
              wasInvited = true;
            },
            invited: false,
            isJoining: false,
          ),
        ),
      );

      expect(find.text('Invite'), findsOneWidget);
      expect(wasInvited, isFalse);

      await tester.tap(find.text('Invite'));
      await tester.pump();

      expect(find.text('Invited'), findsOneWidget);
      expect(wasInvited, isTrue);
    });

    testWidgets(
        'InvitationTile does not show invite button when isJoining is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: InvitationTile(
            user: user,
            invitePageKey: (uid) {},
            invited: false,
            isJoining: true,
          ),
        ),
      );

      expect(find.text('Invite'), findsNothing);
      expect(find.text('Invited'), findsNothing);
    });
  });
}
