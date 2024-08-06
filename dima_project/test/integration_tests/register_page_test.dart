import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/widgets/auth/registration_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
  });

  testWidgets('Initial page shows Credentials Information',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
        ),
      ),
    );
    expect(find.text('Credentials Information'), findsOneWidget);
    expect(find.byType(CredentialsInformationForm), findsOneWidget);
  });

  testWidgets('Navigates to Personal Information form on next button press',
      (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken("test@example.com"))
        .thenAnswer((_) async => Future.value(false));
    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
        ),
      ),
    );

    // Fill in the credentials form and press next
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');
    await tester.enterText(
        find.byType(CupertinoTextField).at(2), 'password123');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.byType(PersonalInformationForm), findsOneWidget);
  });

  testWidgets('Shows error dialog if email is already taken',
      (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken('test@example.com'))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
        ),
      ),
    );
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');
    await tester.enterText(
        find.byType(CupertinoTextField).at(2), 'password123');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid choice'), findsOneWidget);
    expect(find.text('Email is already taken.'), findsOneWidget);
  });

  testWidgets(
      'Navigates back to credentials form from personal information form',
      (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken('test@example.com'))
        .thenAnswer((_) async => false);
    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
        ),
      ),
    );
    // Fill in the credentials form and press next
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');
    await tester.enterText(
        find.byType(CupertinoTextField).at(2), 'password123');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Navigate back
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    expect(find.text('Credentials Information'), findsOneWidget);
    expect(find.byType(CredentialsInformationForm), findsOneWidget);
  });
}
