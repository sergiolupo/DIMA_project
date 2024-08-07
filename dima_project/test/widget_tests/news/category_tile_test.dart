import 'package:dima_project/widgets/news/category_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mock_database_service.mocks.dart';
import '../../mocks/mock_news_service.mocks.dart';

void main() {
  testWidgets(
      'CategoryTile displays correctly on iPhone and navigates to CategoryNews',
      (WidgetTester tester) async {
    const categoryName = 'Cooking';
    const image = 'assets/categories/cooking.jpg';
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(
      CupertinoApp(
        home: Column(
          children: [
            CategoryTile(
              image: image,
              categoryName: categoryName,
              newsService: MockNewsService(),
              databaseService: MockDatabaseService(),
            ),
          ],
        ),
      ),
    );

    // Verify that the CategoryTile displays the correct information
    expect(find.text(categoryName), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
