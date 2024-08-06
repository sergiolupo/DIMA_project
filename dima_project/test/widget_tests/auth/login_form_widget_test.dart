import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:dima_project/widgets/auth/registration_form_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/services/auth_service.dart';

import '../../mocks/mock_auth_service.mocks.dart';
import '../../mocks/mock_database_service.mocks.dart';

class MockUser extends Mock implements User {
  @override
  late final String uid;
  @override
  late final String email;
  MockUser(this.uid, this.email);
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
        .thenAnswer((_) async => MockUser("test-uuid", "mail@mail.com"));
    when(mockDatabaseService.checkUserExist("mail@mail.com"))
        .thenAnswer((_) async => false);
    await tester.pumpWidget(CupertinoApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return LoginForm(
                  usernameController,
                  passwordController,
                  authService: mockAuthService,
                  databaseService: mockDatabaseService,
                );
              }),
          GoRoute(
              path: '/register',
              builder: (BuildContext context, GoRouterState state) {
                User? user = state.extra as User?;
                return RegisterPage(
                    user: user, databaseService: mockDatabaseService);
              }),
        ],
      ),
    ));
    await tester.tap(find.text('Sign In with Google'));
    await tester.pumpAndSettle();

    verify(mockAuthService.signInWithGoogle()).called(1);

    expect(find.byType(PersonalInformationForm), findsOneWidget);
  });
}
