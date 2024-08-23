import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/add_member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AddMemberTile widget test', (WidgetTester tester) async {
    bool selectionChanged = false;
    final testUser = UserData(
        uid: '12345',
        username: 'test_user',
        name: 'Test',
        surname: 'User',
        imagePath: '',
        categories: [],
        email: 'email');

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: AddMemberTile(
            user: testUser,
            onSelected: (uid) {
              selectionChanged = uid == '12345';
            },
            active: false,
            isJoining: false,
          ),
        ),
      ),
    );

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test_user'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.check_mark), findsNothing);

    await tester.tap(find.byIcon(CupertinoIcons.circle));
    await tester.pumpAndSettle();

    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.circle), findsNothing);
    expect(selectionChanged, true);
  });
}
