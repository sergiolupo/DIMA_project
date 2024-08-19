import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/pages/events/table_calendar_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_event_service.mocks.dart';
import '../mocks/mock_image_picker.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  late final MockImagePicker mockImagePicker;
  late final MockEventService mockEventService;
  late final MockNotificationService mockNotificationService;
  late final MockDatabaseService mockDatabaseService;
  final Event fakeEvent1 = Event(
      id: "123",
      name: "Test Event",
      description: "Test Description",
      admin: "Test Admin",
      imagePath: "",
      isPublic: true,
      details: [
        EventDetails(
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 2),
            startTime: DateTime(2024, 1, 1, 0, 0),
            endTime: DateTime(2024, 1, 2, 1, 0),
            location: "Test Location",
            latlng: const LatLng(0, 0),
            id: "321",
            members: ["Test Admin", "uid"])
      ]);
  final Event fakeEvent2 = Event(
      id: "456",
      name: "Test Event",
      description: "Test Description",
      admin: "uid",
      imagePath: "",
      isPublic: true,
      details: [
        EventDetails(
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 2),
            startTime: DateTime(2024, 1, 1, 0, 0),
            endTime: DateTime(2024, 1, 2, 1, 0),
            location: "Test Location",
            latlng: const LatLng(0, 0),
            id: "654",
            members: ["uid"])
      ]);
  group("Event tests", () {
    setUpAll(() {
      nock.init();
      mockImagePicker = MockImagePicker();
      mockEventService = MockEventService();
      mockNotificationService = MockNotificationService();
      mockDatabaseService = MockDatabaseService();
    });

    setUp(() {
      nock.cleanAll();
    });
    testWidgets("Event page renders correctly and navigation works",
        (WidgetTester tester) async {
      AuthService.setUid("uid");

      nock('https://tile.openstreetmap.org')
          .get('/{z}/{x}/{y}.png')
          .reply(200, 'OK');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent1,
            ),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            userProvider.overrideWith((ref, uid) async {
              if (uid == "uid") {
                return Future.value(UserData(
                  uid: "uuid",
                  email: "email1",
                  imagePath: "",
                  categories: [],
                  name: "name",
                  surname: "surname",
                  username: "username",
                  requests: [],
                ));
              } else {
                return Future.value(UserData(
                  uid: "Test Admin",
                  email: "email2",
                  imagePath: "",
                  categories: [],
                  name: "admin",
                  surname: "admin",
                  username: "admin",
                  requests: [],
                ));
              }
            }),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent1.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      expect(find.text("Event"), findsOneWidget);
      await tester.tap(find.byType(CupertinoListTile));
      await tester.pumpAndSettle();
      expect(find.text("Detail Page"), findsOneWidget);
      expect(find.text("Location: Test Location"), findsOneWidget);
      expect(find.textContaining("Add to calendar"), findsOneWidget);
      expect(find.text("Participants"), findsOneWidget);
      await tester.tap(find.text("Participants"));
      await tester.pumpAndSettle();
      expect(find.text("Participants"), findsOneWidget);
      expect(find.text("admin"), findsOneWidget);
      expect(find.text("admin admin"), findsOneWidget);
      expect(find.text("username"), findsOneWidget);
      expect(find.text("name surname"), findsOneWidget);
      expect(find.text("Host"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();
      expect(find.text("Detail Page"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
    });

    testWidgets("Delete event works", (WidgetTester tester) async {
      AuthService.setUid("uid");
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent2,
            ),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent1.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      await tester.tap(find.text('Delete Event'));
      await tester.pumpAndSettle();
      expect(find.text("Are you sure you want to delete this event?"),
          findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      await tester.tap(find.text("Delete Event"));
      await tester.pumpAndSettle();
      expect(find.text("Are you sure you want to delete this event?"),
          findsOneWidget);
      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();
    });
    testWidgets("Edit event page works correctly", (WidgetTester tester) async {
      AuthService.setUid("uid");
      when(mockDatabaseService.getGroups(any)).thenAnswer(
        (_) => Future.value([]),
      );

      when(mockDatabaseService.updateEvent(any, any, any, any, any, any))
          .thenAnswer((_) {
        return Future.value();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent2,
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent2.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      await tester.tap(find.text("Edit"));
      await tester.pumpAndSettle();
      expect(find.text("Edit Event"), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField).at(0), "");
      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.text("Event name is required"), findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoTextField).at(0), "Test Event1");

      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsNWidgets(3));

      await tester.tap(find.text("Add more dates"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsNWidgets(8));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsNWidgets(3));
      await tester.tap(find.text("Participants"));
      await tester.pumpAndSettle();
      expect(find.text("Add Members"), findsOneWidget);
      expect(find.text("No followers"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.text("No groups"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
    });
    testWidgets("Create Event Page test", (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent1,
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: CreateEventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              canNavigate: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
    testWidgets("Table Calendar Page test", (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent1,
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: TableCalendarPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
