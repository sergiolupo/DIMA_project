import 'package:dima_project/models/event.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/event_request_tile.dart';
import 'package:flutter/cupertino.dart';

class EventsRequestsPage extends StatefulWidget {
  final String uuid;
  const EventsRequestsPage({super.key, required this.uuid});
  @override
  EventsRequestsPageState createState() => EventsRequestsPageState();
}

class EventsRequestsPageState extends State<EventsRequestsPage> {
  Stream<List<dynamic>>? eventRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    eventRequests = DatabaseService.getEventRequestsStream(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return eventRequests == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Event Requests'),
              leading: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(CupertinoIcons.back),
              ),
            ),
            child: SafeArea(
              child: StreamBuilder<List<dynamic>>(
                stream: eventRequests,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List requests =
                        snapshot.data!.map((doc) => doc).toList();
                    return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<Event>(
                            stream: DatabaseService.getEventFromId(
                              requests[index],
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final event = snapshot.data!;
                                return EventRequestTile(
                                    event: event, uuid: widget.uuid);
                              } else {
                                return const Center(
                                  child: CupertinoActivityIndicator(),
                                );
                              }
                            },
                          );
                        });
                  } else {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                },
              ),
            ),
          );
  }
}
