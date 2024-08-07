import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_auth_service.mocks.dart';
import '../mocks/mock_database_service.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<void> sendPasswordResetEmail(
      {ActionCodeSettings? actionCodeSettings, required String email}) async {
    return;
  }
}

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockAuthService mockAuthService;
  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockAuthService = MockAuthService();
  });

  testWidgets("Login and Forgot Password pages display correctly",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: LoginPage(
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );

    expect(find.text('AGORAPP'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign In with Google'), findsOneWidget);
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset Password'), findsOneWidget);
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets("Login with invalid credentials", (WidgetTester tester) async {
    when(mockAuthService.signInWithEmailAndPassword(
            'test@example.com', 'password123'))
        .thenThrow(FirebaseAuthException(
            message: "Invalid username or password",
            code: "invalid-credentials"));

    await tester.pumpWidget(
      CupertinoApp(
        home: LoginPage(
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login Failed'), findsOneWidget);
    expect(find.text('Invalid username or password'), findsOneWidget);
  });
  testWidgets("Login with valid credentials", (WidgetTester tester) async {
    when(mockAuthService.signInWithEmailAndPassword(
            'test@example.com', 'password123'))
        .thenAnswer(
            (_) async => Future.delayed(const Duration(milliseconds: 1)));
    AuthService.setUid('test');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          userProvider.overrideWith(
            (ref, uid) => Future.value(UserData(
                uid: 'test',
                email: 'mail',
                username: 'username',
                imagePath: '',
                categories: ['category'],
                name: 'name',
                surname: 'surname')),
          ),
          followingProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          groupsProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          joinedEventsProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          createdEventsProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          followerProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
        ],
        child: CupertinoApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                  path: '/',
                  builder: (BuildContext context, GoRouterState state) {
                    return LoginPage(
                      databaseService: DatabaseService(),
                      authService: AuthService(),
                    );
                  }),
              GoRoute(
                  path: '/home',
                  builder: (BuildContext context, GoRouterState state) {
                    return const HomePage(index: 0);
                  }),
            ],
          ),
        ),
      ),
    );
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoTabView), findsOneWidget); // Home page
  });
}
