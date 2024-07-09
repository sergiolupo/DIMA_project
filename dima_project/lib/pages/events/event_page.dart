import 'dart:async';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/widgets/home/show_event_members.dart';
import 'package:dima_project/widgets/show_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:dima_project/pages/events/edit_event_page.dart';

class EventPage extends StatefulWidget {
  final String uuid;
  final String eventId;

  const EventPage({super.key, required this.eventId, required this.uuid});

  @override
  State<EventPage> createState() => EventPageState();
}

class EventPageState extends State<EventPage> {
  Stream<Event>? _eventStream;
  int _isJoining = 0;
  @override
  void initState() {
    init();
    _checkJoin();
    super.initState();
  }

  init() {
    _eventStream = DatabaseService.getEventStream(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return _eventStream == null
        ? const Center(
            child: CupertinoActivityIndicator(),
          )
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoColors.systemPink,
              trailing: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => EditEventPage(
                              eventId: widget.eventId,
                            ))),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              leading: Navigator.canPop(context)
                  ? CupertinoNavigationBarBackButton(
                      color: CupertinoColors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  : null,
              middle: const Text(
                'Event',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
            child: StreamBuilder<Event>(
              stream: _eventStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final event = snapshot.data!;
                  return SafeArea(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  CreateImageWidget.getEventImage(
                                      event.imagePath!),
                                  Text(
                                    event.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 50),
                              Column(children: [
                                Text(
                                  event.members.length.toString(),
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            ShowEventMembersPage(
                                          uuid: widget.uuid,
                                          eventId: event.id!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    event.members.length > 1
                                        ? " Participants"
                                        : " Participant",
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .copyWith(
                                            color: CupertinoColors.systemGrey),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                CupertinoButton.filled(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 8),
                                  onPressed: () async {
                                    DatabaseService.toggleEventJoin(
                                        widget.eventId, widget.uuid);
                                  },
                                  child: Text(
                                    _isJoining == 0
                                        ? "Subscribe"
                                        : _isJoining == 1
                                            ? "Unsubscribe"
                                            : "Requested",
                                  ),
                                ),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: CupertinoColors.lightBackgroundGray,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    event.description,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShowDate(date: event.startDate),
                              const Text(
                                ' - ',
                              ),
                              ShowDate(date: event.endDate)
                            ],
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder(
                              future: EventService.getAddressFromLatLng(
                                  event.location),
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
                                  initialCenter: event.location,
                                  initialZoom: 11,
                                  interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all),
                                ),
                                children: [
                                  openStreetMapTileLayer,
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        width: 80.0,
                                        height: 80.0,
                                        point: event.location,
                                        child: Icon(
                                          CupertinoIcons.location_solid,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                          ),
                        ],

                        /*StreamBuilder<UserData>(
                                  stream: DatabaseService.getUserDataFromUUID(
                                      event.admin),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final admin = snapshot.data!;
                                      return Text(
                                        'Host: ${admin.username}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: CupertinoActivityIndicator(),
                                      );
                                    }
                                  },
                                ),*/
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              },
            ),
          );
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'polimi.dima_project.agorapp',
      );
  _checkJoin() async {
    // Listen for updates on the isFollowing stream
    final isJoiningStream = DatabaseService.isJoining(
      widget.uuid,
      widget.eventId,
    );

    // Listen for updates and update _isFollowing accordingly
    await for (final isJoining in isJoiningStream) {
      if (mounted) {
        setState(() {
          _isJoining = isJoining;
        });
      }
    }
  }
}
