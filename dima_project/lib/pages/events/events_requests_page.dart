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
  List<Event>? eventRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    final requests = await DatabaseService.getEventRequestsForUser(widget.uuid);
    setState(() {
      eventRequests = requests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return eventRequests == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Event Requests'),
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(CupertinoIcons.back),
              ),
            ),
            child: SafeArea(
              child: ListView.builder(
                itemCount: eventRequests!.length,
                itemBuilder: (context, index) {
                  return EventRequestTile(
                      event: eventRequests![index], uuid: widget.uuid);
                },
              ),
            ),
          );
  }
}
