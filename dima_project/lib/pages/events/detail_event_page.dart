import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/home/show_event_members.dart';
import 'package:dima_project/widgets/show_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailPage extends ConsumerStatefulWidget {
  final String uuid;
  final String eventId;
  final String detailId;

  const DetailPage({
    super.key,
    required this.uuid,
    required this.eventId,
    required this.detailId,
  });
  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends ConsumerState<DetailPage> {
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
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text('Detail Page',
              style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
          trailing: event.admin == widget.uuid
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
                            'Are you sure you want to delete this event?'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          CupertinoDialogAction(
                            child: const Text('Delete'),
                            onPressed: () async {
                              Navigator.of(newContext).pop();
                              await DatabaseService.deleteDetail(
                                  event.id!, widget.detailId);
                              ref.invalidate(eventProvider(event.id!));
                              ref.invalidate(
                                  createdEventsProvider(widget.uuid));
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
              : null,
          leading: Navigator.canPop(context)
              ? CupertinoNavigationBarBackButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  onPressed: () {
                    ref.invalidate(eventProvider(event.id!));
                    ref.invalidate(joinedEventsProvider(widget.uuid));
                    ref.invalidate(createdEventsProvider(widget.uuid));
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
                ShowDate(date: detail.startDate!, time: detail.startTime!),
                const Text(
                  ' - ',
                ),
                ShowDate(date: detail.endDate!, time: detail.endTime!)
              ],
            ),
            FutureBuilder(
                future: EventService.getAddressFromLatLng(detail.latlng!),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final address = snapshot.data as String;
                    return Text(
                      'Location: $address',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    );
                  } else {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                }),
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.9,
              child: FlutterMap(
                  options: MapOptions(
                    initialCenter: detail.latlng!,
                    initialZoom: 11,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    openStreetMapTileLayer,
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: detail.latlng!,
                          child: Icon(
                            CupertinoIcons.location_solid,
                            color: CupertinoTheme.of(context).primaryColor,
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
                      uuid: widget.uuid,
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
            if (event.admin != widget.uuid &&
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
                    debugPrint('Joining event');
                    await DatabaseService.toggleEventJoin(
                        event.id!, detail.id!, widget.uuid);
                    ref.invalidate(eventProvider(event.id!));
                    ref.invalidate(joinedEventsProvider(widget.uuid));
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
                                ref.invalidate(
                                    joinedEventsProvider(widget.uuid));
                                ref.invalidate(
                                    createdEventsProvider(widget.uuid));
                                Navigator.of(context).pop();
                                Navigator.of(newContext).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  detail.members!.contains(widget.uuid)
                      ? "Unsubscribe"
                      : detail.requests!.contains(widget.uuid)
                          ? "Requested"
                          : "Subscribe",
                ),
              ),
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
