import 'dart:async';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/detail_event_page.dart';
import 'package:dima_project/widgets/home/show_event_members.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';

import 'package:dima_project/pages/events/edit_event_page.dart';
import 'package:intl/intl.dart';

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
        : StreamBuilder<Event>(
            stream: _eventStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final event = snapshot.data!;
                return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    backgroundColor: CupertinoColors.systemPink,
                    trailing: CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => EditEventPage(
                                    event: event,
                                    uuid: widget.uuid,
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
                  child: SafeArea(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CreateImageWidget.getEventImage(event.imagePath!),
                              const SizedBox(width: 50),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            textAlign: TextAlign.start,
                            event.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
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
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: event.details.length,
                            itemBuilder: (BuildContext context, int index) {
                              final detail = event.details[index];
                              return CupertinoListTile(
                                title: Column(
                                  children: [
                                    Text(
                                        '${DateFormat('dd/MM/yyyy').format(detail.startDate!)}-${DateFormat('dd/MM/yyyy').format(detail.endDate!)}'),
                                  ],
                                ),
                                trailing: const Icon(CupertinoIcons.forward),
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => DetailPage(
                                        event: event,
                                        detail: detail,
                                        uuid: widget.uuid,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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
                  ),
                );
              } else {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          );
  }

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
