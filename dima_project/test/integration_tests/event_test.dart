import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_image_picker.mocks.dart';

void main() {
  final MockDatabaseService mockDatabaseService = MockDatabaseService();
  final MockImagePicker mockImagePicker = MockImagePicker();
  group("Create event page tests", () {
    testWidgets("", (WidgetTester tester) async {});
  });
}
