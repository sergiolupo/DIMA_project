import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/user_tile.dart';

import '../mocks/mock_database_service.dart';

void main() {
  final UserData testUser = UserData(
    categories: ['test_category'],
    email: '',
    uid: 'test_user',
    username: 'test_username',
    name: 'Test',
    surname: 'User',
    imagePath: '',
  );

  Widget createWidgetForTesting({required Widget child}) {
    return ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(child: child),
        ),
      ),
    );
  }

  testWidgets('UserTile displays user information',
      (WidgetTester tester) async {
    AuthService.setUid('user_id');
    await tester.pumpWidget(createWidgetForTesting(
      child: UserTile(user: testUser, isFollowing: 0),
    ));

    expect(find.text(testUser.username), findsOneWidget);
    expect(find.text('${testUser.name} ${testUser.surname}'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('UserTile shows unfollow button when following',
      (WidgetTester tester) async {
    AuthService.setUid('user_id');

    await tester.pumpWidget(createWidgetForTesting(
      child: UserTile(user: testUser, isFollowing: 1),
    ));
    expect(find.text('Unfollow'), findsOneWidget);
  });
}
