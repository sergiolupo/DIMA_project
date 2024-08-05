import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/events/event_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/event.dart';

void main() {
  final Event testEvent = Event(
    id: '123',
    name: 'Event',
    description: 'Description',
    imagePath: '',
    admin: 'uid',
    isPublic: true,
  );
  testWidgets('EventTile displays event name and description',
      (WidgetTester tester) async {
    AuthService.setUid('uid');
    await tester.pumpWidget(ProviderScope(
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: EventTile(event: testEvent),
        ),
      ),
    ));

    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Description: Description'), findsOneWidget);
  });
}
