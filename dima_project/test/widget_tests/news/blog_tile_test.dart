import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:dima_project/pages/news/article_view.dart';

void main() {
  testWidgets('BlogTile displays correctly', (WidgetTester tester) async {
    const imageUrl = 'https://via.placeholder.com/150';
    const title = 'Sample Blog Title';
    const description = 'This is a sample description for the blog tile.';
    const url = 'https://example.com';

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: Column(
            children: [
              BlogTile(
                imageUrl: imageUrl,
                title: title,
                description: description,
                url: url,
              ),
            ],
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleView), findsOneWidget);
    });
  });
}
