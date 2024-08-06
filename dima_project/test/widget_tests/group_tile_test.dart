import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/widgets/group_tile.dart';

import '../mocks/mock_database_service.mocks.dart';

void main() {
  final Group testGroup = Group(
    id: '123',
    name: 'Group',
    imagePath: '',
    isPublic: true,
  );

  testWidgets('GroupTile displays group name and image',
      (WidgetTester tester) async {
    AuthService.setUid('uid');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: GroupTile(group: testGroup, isJoined: 1),
          ),
        ),
      ),
    ));

    final nameFinder = find.text(testGroup.name);
    final imageFinder = find.byType(Image);

    expect(nameFinder, findsOneWidget);
    expect(imageFinder, findsOneWidget);
  });
}
