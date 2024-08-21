import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  group('CreateImageWidget Tests', () {
    testWidgets('getUserImage displays correct size and image from network',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          CupertinoApp(
            home: CupertinoPageScaffold(
              child: CreateImageWidget.getUserImage(
                  'https://example.com/user.png', 1),
            ),
          ),
        );
      });

      final container = tester.widget<Container>(find.byType(Container));
      final constraints = container.constraints as BoxConstraints;

      expect(constraints.maxWidth, 100);
      expect(constraints.maxHeight, 100);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image).evaluate().single.widget,
          isA<Image>().having((i) => i.image, 'image', isA<NetworkImage>()));
    });

    testWidgets('getGroupImage displays default image when path is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CreateImageWidget.getGroupImage(''),
          ),
        ),
      );

      final Container container =
          tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 100);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image).evaluate().single.widget,
          isA<Image>().having((i) => i.image, 'image', isA<AssetImage>()));
    });

    testWidgets('getEventImageMemory displays default image when path is empty',
        (WidgetTester tester) async {
      final Uint8List imageData = Uint8List(0);
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CreateImageWidget.getEventImageMemory(imageData),
          ),
        ),
      );

      final Container container =
          tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 100);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image).evaluate().single.widget,
          isA<Image>().having((i) => i.image, 'image', isA<AssetImage>()));
    });
    testWidgets('getGroupImageMemory displays default image when path is empty',
        (WidgetTester tester) async {
      final Uint8List imageData = Uint8List(0);
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CreateImageWidget.getGroupImageMemory(imageData),
          ),
        ),
      );

      final Container container =
          tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 100);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image).evaluate().single.widget,
          isA<Image>().having((i) => i.image, 'image', isA<AssetImage>()));
    });

    testWidgets('getUserImageMemory displays correct size for tablet',
        (WidgetTester tester) async {
      final Uint8List imageData = Uint8List(0);

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CreateImageWidget.getUserImageMemory(imageData, true),
          ),
        ),
      );

      final Container container =
          tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 200);
      expect(container.constraints?.maxHeight, 200);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image).evaluate().single.widget,
          isA<Image>().having((i) => i.image, 'image', isA<AssetImage>()));
    });

    testWidgets('getImage displays CachedNetworkImage with correct URL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CreateImageWidget.getImage(
                'https://example.com/event.png', true),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(
          find.byType(CachedNetworkImage).evaluate().single.widget,
          isA<CachedNetworkImage>().having(
              (c) => c.imageUrl, 'imageUrl', 'https://example.com/event.png'));
    });

    testWidgets('getImage displays error widget on error',
        (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          CupertinoApp(
            home: CupertinoPageScaffold(
              child: CreateImageWidget.getImage('', true),
            ),
          ),
        );
      });
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      final imageWidget = find.byType(Image).evaluate().single.widget as Image;
      expect(imageWidget.image, isA<CachedNetworkImageProvider>());
      expect((imageWidget.image as CachedNetworkImageProvider).url, '');
      expect(
          find.byType(Image).evaluate().single.widget,
          isA<Image>()
              .having((i) => i.errorBuilder, 'errorBuilder', isNotNull));
    });
  });
}
