import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class EventRequestTile extends StatefulWidget {
  final Event event;
  final String uuid;
  const EventRequestTile({
    super.key,
    required this.event,
    required this.uuid,
  });

  @override
  EventRequestTileState createState() => EventRequestTileState();
}

class EventRequestTileState extends State<EventRequestTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => EventPage(
              eventId: widget.event.id!,
              uuid: widget.uuid,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: CupertinoListTile(
              leading: CreateImageWidget.getEventImage(widget.event.imagePath!),
              title: Text(
                widget.event.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Description: ${widget.event.description}",
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
