import 'package:dima_project/models/group.dart';
import 'package:dima_project/widgets/group_invitation_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GroupInvitationTile widget test', (WidgetTester tester) async {
    bool isSelected = false;
    final testGroup = Group(
        id: 'group123',
        name: 'Test Group',
        imagePath: '',
        description: 'Test Description',
        members: [],
        requests: [],
        isPublic: true);

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: GroupInvitationTile(
            isFirst: false,
            isLast: false,
            group: testGroup,
            onSelected: (groupId) {
              if (groupId == 'group123') {
                isSelected = true;
              }
            },
            invited: false,
          ),
        ),
      ),
    );

    expect(find.text('Test Group'), findsOneWidget);

    expect(find.text('Invite'), findsOneWidget);
    expect(find.text('Invited'), findsNothing);

    await tester.tap(find.byKey(const Key('invite_button')));
    await tester.pumpAndSettle();

    expect(isSelected, true);
    expect(find.text('Invited'), findsOneWidget);
    expect(find.text('Invite'), findsNothing);
  });
}
