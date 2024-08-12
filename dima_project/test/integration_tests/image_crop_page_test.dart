import 'dart:typed_data';
import 'package:dima_project/pages/image_crop_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_image_picker.mocks.dart';

void main() {
  testWidgets(
      'Verify behavior when no image is selected from the gallery for ImageCropPage',
      (WidgetTester tester) async {
    final imagePicker = MockImagePicker();

    Uint8List insertedImage = Uint8List(0);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(600, 200)),
        child: CupertinoApp(
          home: ImageCropPage(
            imageInsertPageKey: (Uint8List image) {
              insertedImage = image;
            },
            imageType: 0,
            defaultImage: '',
            imagePicker: imagePicker,
          ),
        ),
      ),
    );

    when(imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
      imageQuality: 80,
    )).thenAnswer((_) async => null);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Set New Photo"), findsOneWidget);

    await tester.tap(find.text('Set New Photo'));
    await tester.pumpAndSettle();

    expect(find.text("Camera"), findsOneWidget);
    expect(find.text("Gallery"), findsOneWidget);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(insertedImage, isEmpty);
  });
}
