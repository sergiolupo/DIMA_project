import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/pages/news/news_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/widgets/news/category_tile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_news_service.mocks.dart';

void main() {
  late final MockDatabaseService mockDatabaseService;
  late final MockNewsService mockNewsService;
  List<ArticleModel> news = [
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
  ];

  setUpAll(() {
    AuthService.setUid("test");
    mockDatabaseService = MockDatabaseService();
    mockNewsService = MockNewsService();
  });
  group("News test", () {
    testWidgets("News page renders correctly and navigations work",
        (WidgetTester tester) async {
      when(mockNewsService.getNews()).thenAnswer((_) => Future.value());
      when(mockNewsService.getSliders()).thenAnswer((_) => Future.value());
      when(mockNewsService.getSearchedNews(any))
          .thenAnswer((_) => Stream.value(news));
      when(mockNewsService.getCategoriesNews(any))
          .thenAnswer((_) => Future.value());
      when(mockNewsService.news).thenReturn(news);
      when(mockNewsService.sliders).thenReturn(news.sublist(0, 6));
      when(mockNewsService.news).thenReturn(news);
      when(mockNewsService.sliders).thenReturn(news.sublist(0, 6));
      when(mockNewsService.categories).thenReturn(news);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  uid: 'test',
                  email: 'mail',
                  username: 'username',
                  imagePath: '',
                  categories: [CategoryUtil.categories.first],
                  name: 'name',
                  surname: 'surname')),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp(
            home: NewsPage(
              newsService: mockNewsService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Trending News"), findsOneWidget);
      expect(find.text("Breaking News"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.search)); // Search page
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoTextField), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField), "title1");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text("title1"), findsNWidgets(2));
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CategoryTile)); // Category page
      await tester.pumpAndSettle();
      expect(find.text(CategoryUtil.categories.first), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("View All").first); // All news
      await tester.pumpAndSettle();
      expect(find.text("Breaking News"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("View All").last); // All news
      await tester.pumpAndSettle();
      expect(find.text("Trending News"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    });
    testWidgets(
        "ArticleView and ShareNewsPage display correctly and navigations work",
        (WidgetTester tester) async {
      AuthService.setUid("test");
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('followers').doc('test').set({
        'followers': ['user'],
        'following': ['user'],
      });

      final follower =
          await firestore.collection('followers').doc('test').get();

      when(mockDatabaseService.getGroups(any)).thenAnswer(
        (_) => Future.value([
          Group(
              name: "name",
              id: "id",
              isPublic: true,
              members: ["test", "user"],
              imagePath: "",
              description: "description",
              admin: "test"),
        ]),
      );
      when(mockDatabaseService.getFollowersUser(any)).thenAnswer(
        (_) => Future.value(follower),
      );
      when(mockDatabaseService.shareNewsOnGroups(any, any, any, any, any))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.shareNewsOnFollower(any, any, any, any, any))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.getUserData(any)).thenAnswer(
        (_) => Future.value(UserData(
            uid: 'user',
            email: 'mail',
            username: 'username',
            imagePath: '',
            categories: [CategoryUtil.categories.first],
            name: 'name',
            surname: 'surname')),
      );
      when(mockDatabaseService.shareNewsOnGroups(any, any, any, any, any))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.shareNewsOnFollower(any, any, any, any, any))
          .thenAnswer((_) => Future.value());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  uid: 'test',
                  email: 'mail',
                  username: 'username',
                  imagePath: '',
                  categories: [CategoryUtil.categories.first],
                  name: 'name',
                  surname: 'surname')),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp(
            home: ArticleView(
              blogUrl: 'https://example.com',
              description: 'Test Description',
              imageUrl: 'https://example.com/image.png',
              title: 'Test Title',
              databaseService: mockDatabaseService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WebView), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.share));
      await tester.pumpAndSettle();
      expect(find.text("Send To"), findsOneWidget);
      expect(find.text("Groups"), findsOneWidget);
      expect(find.text("Followers"), findsOneWidget);
      expect(find.text("name"), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text("name"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Followers"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("username"));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(LineAwesomeIcons.paper_plane));
      await tester.pumpAndSettle();
    });
  });
}
