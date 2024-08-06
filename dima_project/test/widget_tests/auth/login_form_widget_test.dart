import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/services/auth_service.dart';

import '../../mocks/mock_auth_service.mocks.dart';
import '../../mocks/mock_database_service.mocks.dart';

class MockUser extends Mock implements User {
  @override
  late final String uid;
  MockUser(this.uid);
}

void main() {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late AuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;
  setUp(() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
  });

  tearDown(() {
    usernameController.dispose();
    passwordController.dispose();
  });

  testWidgets('LoginForm renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(CupertinoApp(
      home: LoginForm(
        usernameController,
        passwordController,
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));

    expect(find.byType(EmailInputField), findsOneWidget);
    expect(find.byType(PasswordInputField), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign In with Google'), findsOneWidget);
  });

  testWidgets('LoginForm shows validation errors', (WidgetTester tester) async {
    await tester.pumpWidget(CupertinoApp(
      home: LoginForm(
        usernameController,
        passwordController,
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
  });

  testWidgets('LoginForm shows error dialog on login failure',
      (WidgetTester tester) async {
    // Mocking the signInWithEmailAndPassword method to throw an exception
    when(mockAuthService.signInWithEmailAndPassword(
            "not-exist@gmail.com", '123456'))
        .thenThrow(FirebaseAuthException(
            message: "Invalid username or password",
            code: "invalid-credentials"));

    await tester.pumpWidget(CupertinoApp(
      home: LoginForm(
        usernameController,
        passwordController,
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.enterText(find.byType(EmailInputField), "not-exist@gmail.com");
    await tester.enterText(find.byType(PasswordInputField), '123456');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login Failed'), findsOneWidget);
    expect(find.text('Invalid username or password'), findsOneWidget);
  });

  testWidgets('LoginForm calls signInWithGoogle on button tap',
      (WidgetTester tester) async {
    // Mocking the signInWithGoogle method to return a MockUser
    when(mockAuthService.signInWithGoogle())
        .thenAnswer((_) async => MockUser("test-uuid"));

    await tester.pumpWidget(CupertinoApp(
      home: LoginForm(
        usernameController,
        passwordController,
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));
    // Tap the Google sign-in button
    await tester.tap(find.text('Sign In with Google'));
    await tester.pumpAndSettle(); // Wait for the UI to settle

    // Verify that the signInWithGoogle method was called
    verify(mockAuthService.signInWithGoogle()).called(1);
  });
}
