import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/message.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../mocks/mock_database_service.mocks.dart';
import '../../mocks/mock_notification_service.mocks.dart';

void main() {
  testWidgets('ImageMessageTile displays correctly',
      (WidgetTester tester) async {
    AuthService.setUid('test_uid');
    final message = Message(
      content: 'image_url',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
      senderImage: '',
      isGroupMessage: false,
      sender: 'test_uid',
      readBy: [
        ReadBy(
          username: 'test_uid',
          readAt: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
        ),
      ],
      type: Type.image,
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        CupertinoApp(
          home: ImageMessageTile(
            message: message,
            showCustomSnackbar: () {},
            databaseService: MockDatabaseService(),
            notificationService: MockNotificationService(),
          ),
        ),
      );
    });

    expect(find.byType(Image), findsOneWidget);

    expect(find.byType(Text), findsOneWidget); //TimeStamp
  });
}
