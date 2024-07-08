import 'dart:async';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter_map/flutter_map.dart';

class EventPage extends StatefulWidget {
  final String uuid;
  final String eventId;

  const EventPage({super.key, required this.eventId, required this.uuid});

  @override
  State<EventPage> createState() => EventPageState();
}

class EventPageState extends State<EventPage> {
  Stream<Event>? _eventStream;

  @override
  void initState() {
    init();
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
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Event'),
            ),
            child: StreamBuilder<Event>(
              stream: _eventStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final event = snapshot.data!;
                  return ListView(
                    children: [
                      Text('Members ${event.members.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CreateImageWidget.getEventImage(event.imagePath!),
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            StreamBuilder<UserData>(
                              stream: DatabaseService.getUserDataFromUUID(
                                  event.admin),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final admin = snapshot.data!;
                                  return Column(
                                    children: [
                                      Text(
                                        'Admin: ${admin.username}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                }
                              },
                            ),
                            Text(
                              'Description: ${event.description}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Date: ${event.date}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 300,
                              child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: event.location,
                                    initialZoom: 11,
                                    interactionOptions:
                                        const InteractionOptions(
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
                        ),
                      ),
                    ],
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
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'polimi.dima_project.agorapp',
      );
}
