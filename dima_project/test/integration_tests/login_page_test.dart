import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';

import '../mocks/mock_auth_service.mocks.dart';
import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_news_service.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<void> sendPasswordResetEmail(
      {ActionCodeSettings? actionCodeSettings, required String email}) async {
    return;
  }
}

void main() {
  late final MockDatabaseService mockDatabaseService;
  late final MockAuthService mockAuthService;
  late final MockNewsService mockNewsService;
  setUp(() {
    nock.cleanAll();
    mockDatabaseService = MockDatabaseService();
    mockAuthService = MockAuthService();
    mockNewsService = MockNewsService();
  });

  group("Login Page Tests ", () {
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
      when(mockNewsService.getNews()).thenAnswer((_) => Future.value());
      when(mockNewsService.getSliders()).thenAnswer((_) => Future.value());
      when(mockNewsService.news).thenReturn([
        ArticleModel(
            title: 'title1',
            description: 'description1',
            url: 'url1',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title2',
            description: 'description2',
            url: 'url2',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title3',
            description: 'description3',
            url: 'url3',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title4',
            description: 'description4',
            url: 'url4',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title5',
            description: 'description5',
            url: 'url5',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title6',
            description: 'description6',
            url: 'url6',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title7',
            description: 'description7',
            url: 'url7',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title8',
            description: 'description8',
            url: 'url8',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title9',
            description: 'description9',
            url: 'url9',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title10',
            description: 'description10',
            url: 'url10',
            urlToImage: 'https://example.com/news.png'),
      ]);
      when(mockNewsService.sliders).thenReturn([
        ArticleModel(
            title: 'title1',
            description: 'description1',
            url: 'url1',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title2',
            description: 'description2',
            url: 'url2',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title3',
            description: 'description3',
            url: 'url3',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title4',
            description: 'description4',
            url: 'url4',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title5',
            description: 'description5',
            url: 'url5',
            urlToImage: 'https://example.com/news.png'),
        ArticleModel(
            title: 'title6',
            description: 'description6',
            url: 'url6',
            urlToImage: 'https://example.com/news.png'),
      ]);

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
                  categories: [],
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
                        databaseService: mockDatabaseService,
                        authService: mockAuthService,
                      );
                    }),
                GoRoute(
                    path: '/home',
                    builder: (BuildContext context, GoRouterState state) {
                      return HomePage(
                        index: 0,
                        newsService: mockNewsService,
                      );
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

      expect(find.text("Trending News"), findsOneWidget); // Home page
    });
  });
}
