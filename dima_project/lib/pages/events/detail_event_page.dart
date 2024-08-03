import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/pages/user_profile/show_event_members_page.dart';
import 'package:dima_project/widgets/events/show_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';

class DetailPage extends ConsumerStatefulWidget {
  final String eventId;
  final String detailId;

  const DetailPage({
    super.key,
    required this.eventId,
    required this.detailId,
  });
  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends ConsumerState<DetailPage> {
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(eventProvider(widget.eventId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventProvider(widget.eventId));
    return event.when(data: (event) {
      final detail = event.details!.firstWhere(
        (element) => element.id == widget.detailId,
        orElse: () => throw Exception('Detail not found'),
      );
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text('Detail Page',
              style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
          leading: Navigator.canPop(context)
              ? CupertinoNavigationBarBackButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  onPressed: () {
                    ref.invalidate(eventProvider(event.id!));
                    ref.invalidate(joinedEventsProvider(uid));
                    ref.invalidate(createdEventsProvider(uid));
                    Navigator.of(context).pop();
                  },
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowDateWidget(
                    date: detail.startDate!, time: detail.startTime!),
                const Text(
                  ' - ',
                ),
                ShowDateWidget(date: detail.endDate!, time: detail.endTime!)
              ],
            ),
            Text(
              'Location: ${detail.location}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.9,
              child: FlutterMap(
                  options: MapOptions(
                    initialCenter: detail.latlng!,
                    initialZoom: 11,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    openStreetMapTileLayer,
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: detail.latlng!,
                          child: CupertinoButton(
                            onPressed: () async {
                              final coords = Coords(detail.latlng!.latitude,
                                  detail.latlng!.longitude);
                              final title = event.name;
                              final availableMaps =
                                  await MapLauncher.installedMaps;

                              if (context.mounted) {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext newContext) {
                                    return CupertinoActionSheet(
                                      actions: [
                                        for (var map in availableMaps)
                                          CupertinoActionSheetAction(
                                            onPressed: () => map.showMarker(
                                              coords: coords,
                                              title: title,
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  map.icon,
                                                  height: 30.0,
                                                  width: 30.0,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(map.mapName),
                                              ],
                                            ),
                                          )
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () =>
                                            Navigator.pop(newContext),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: CupertinoColors.systemRed),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            child: Icon(
                              CupertinoIcons.location_solid,
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
            const SizedBox(height: 20),
            Text(
              detail.members!.length.toString(),
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => ShowEventMembersPage(
                      eventId: widget.eventId,
                      detailId: widget.detailId,
                      admin: event.admin,
                    ),
                  ),
                );
              },
              child: Text(
                detail.members!.length > 1 ? " Participants" : " Participant",
                style: CupertinoTheme.of(context)
                    .textTheme
                    .textStyle
                    .copyWith(color: CupertinoColors.systemGrey),
              ),
            ),
            const SizedBox(height: 20),
            if (event.admin != uid &&
                DateTime.now().isBefore(DateTime(
                  detail.startDate!.year,
                  detail.startDate!.month,
                  detail.startDate!.day,
                  detail.startTime!.hour,
                  detail.startTime!.minute,
                )))
              CupertinoButton.filled(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                onPressed: () async {
                  try {
                    if (!DateTime.now().isBefore(DateTime(
                      detail.startDate!.year,
                      detail.startDate!.month,
                      detail.startDate!.day,
                      detail.startTime!.hour,
                      detail.startTime!.minute,
                    ))) {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext newContext) {
                          return CupertinoAlertDialog(
                            title: const Text('Event in progress'),
                            content: const Text('Event has already started.'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () {
                                  ref.invalidate(eventProvider(event.id!));
                                  ref.invalidate(joinedEventsProvider(uid));
                                  ref.invalidate(createdEventsProvider(uid));
                                  Navigator.of(newContext).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }
                    debugPrint('Joining event');
                    await DatabaseService.toggleEventJoin(
                      event.id!,
                      detail.id!,
                    );
                    ref.invalidate(eventProvider(event.id!));
                    ref.invalidate(joinedEventsProvider(uid));
                  } catch (e) {
                    debugPrint("Event has been deleted");
                    if (!context.mounted) return;
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext newContext) {
                        return CupertinoAlertDialog(
                          title: const Text('Event has been deleted'),
                          content: const Text('This date has been deleted.'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () {
                                ref.invalidate(eventProvider(event.id!));
                                ref.invalidate(joinedEventsProvider(uid));
                                ref.invalidate(createdEventsProvider(uid));
                                Navigator.of(newContext).pop();

                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  detail.members!.contains(uid)
                      ? "Unsubscribe"
                      : detail.requests!.contains(uid)
                          ? "Requested"
                          : "Subscribe",
                ),
              ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              event.admin == uid
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(CupertinoIcons.trash,
                          color: CupertinoTheme.of(context).primaryColor),
                      onPressed: () async {
                        // Show confirmation dialog
                        showCupertinoDialog(
                          context: context,
                          builder: (newContext) => CupertinoAlertDialog(
                            title: const Text('Date cancellation'),
                            content: const Text(
                                'Are you sure you want to delete this date?'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              CupertinoDialogAction(
                                child: const Text('Delete'),
                                onPressed: () async {
                                  Navigator.of(newContext).pop();
                                  BuildContext buildContext = context;
                                  // Show the loading dialog
                                  showCupertinoDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext newContext) {
                                      buildContext = newContext;
                                      return const CupertinoAlertDialog(
                                        content: CupertinoActivityIndicator(),
                                      );
                                    },
                                  );
                                  await DatabaseService.deleteDetail(
                                      event.id!, widget.detailId);
                                  ref.invalidate(eventProvider(event.id!));
                                  ref.invalidate(createdEventsProvider(uid));
                                  if (buildContext.mounted) {
                                    Navigator.of(buildContext).pop();
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(),
              CupertinoButton(
                onPressed: () async {
                  debugPrint('Adding event to calendar');
                  Add2Calendar.addEvent2Cal(Event(
                    title: event.name,
                    description: event.description,
                    location:
                        await EventService.getAddressFromLatLng(detail.latlng!),
                    startDate: DateTime(
                        detail.startDate!.year,
                        detail.startDate!.month,
                        detail.startDate!.day,
                        detail.startTime!.hour,
                        detail.startTime!.minute),
                    endDate: DateTime(
                        detail.endDate!.year,
                        detail.endDate!.month,
                        detail.endDate!.day,
                        detail.endTime!.hour,
                        detail.endTime!.minute),
                    iosParams: const IOSParams(
                      reminder: Duration(hours: 1),
                    ),
                  ));
                },
                child: Row(
                  children: [
                    Text('Add to calendar',
                        style: TextStyle(
                            color: CupertinoTheme.of(context).primaryColor,
                            fontWeight: FontWeight.bold)),
                    Icon(CupertinoIcons.calendar,
                        color: CupertinoTheme.of(context).primaryColor),
                  ],
                ),
              ),
            ]),
          ],
        ),
      );
    }, loading: () {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }, error: (error, stackTrace) {
      return Center(
        child: Text('Error: $error'),
      );
    });
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'polimi.dima_project.agorapp',
      );
}
