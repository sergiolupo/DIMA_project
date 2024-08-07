import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/options/options_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/option_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';

void main() {
  late final MockDatabaseService mockDatabaseService;

  setUpAll(() {
    mockDatabaseService = MockDatabaseService();
  });
  group("OptionsPage Tests", () {
    testWidgets('OptionsPage renders correctly and navigator works',
        (WidgetTester tester) async {
      AuthService.setUid('testUid');
      when(mockDatabaseService.acceptUserRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.denyUserRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.acceptUserGroupRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.denyUserGroupRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.isUsernameTaken("test"))
          .thenAnswer((_) async => true);
      when(mockDatabaseService.isUsernameTaken("test_username"))
          .thenAnswer((_) async => false);
      when(mockDatabaseService.updateUserInformation(any, any, any, any))
          .thenAnswer((_) async => Future.value());

      when(mockDatabaseService.getFollowRequests('testUid'))
          .thenAnswer((_) async => [
                UserData(
                    categories: [],
                    email: "email",
                    name: "name",
                    surname: "surname",
                    username: "username",
                    imagePath: "",
                    isPublic: false,
                    uid: "uid"),
                UserData(
                    categories: [],
                    email: "email2",
                    name: "name2",
                    surname: "surname2",
                    username: "username2",
                    isPublic: false,
                    imagePath: "",
                    uid: "uid2")
              ]);
      when(mockDatabaseService.getUserGroupRequests('testUid'))
          .thenAnswer((_) async => [
                Group(
                    name: "name",
                    description: "description",
                    members: ["owner"],
                    admin: "owner",
                    id: "id",
                    categories: [],
                    imagePath: '',
                    isPublic: false),
                Group(
                    name: "name2",
                    description: "description2",
                    members: ["owner2"],
                    admin: "owner2",
                    id: "id2",
                    categories: [],
                    imagePath: '',
                    isPublic: false),
              ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  categories: [],
                  email: "test_email",
                  name: "test_name",
                  surname: "test_surname",
                  username: "test_username",
                  isPublic: false,
                  imagePath: "",
                  uid: "testUid")),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: const CupertinoApp(
            home: CupertinoPageScaffold(
              child: OptionsPage(),
            ),
          ),
        ),
      );

      expect(find.text('Options'), findsOneWidget);
      expect(find.byType(OptionTile), findsNWidgets(4));
      await tester.tap(find.byIcon(CupertinoIcons.bell));
      await tester.pumpAndSettle();
      expect(find.text('Requests'), findsOneWidget); //Request page
      await tester.tap(find.byIcon(CupertinoIcons.person)); //Follow requests
      await tester.pumpAndSettle();
      await tester.tap(find.text("Accept").first);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Deny").first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();
      await tester.tap(
          find.byIcon(CupertinoIcons.person_2_square_stack)); //Group requests
      await tester.pumpAndSettle();
      await tester.tap(find.text("Accept").first);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Deny").first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.settings)); //Settings page
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField).at(2), '');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Please fill all the fields'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).at(2), 'test');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Username is already taken'), findsNothing);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoTextField).at(2), 'test_username');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Options'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.back));
    });
  });
}
