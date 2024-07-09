import 'package:dima_project/models/event.dart';
import 'package:dima_project/services/database_service.dart';
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
    return Row(
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
        GestureDetector(
          onTap: () async {
            try {
              await DatabaseService.acceptEventRequest(
                  widget.event.id!, widget.uuid);
            } catch (error) {
              debugPrint("Error occurred: $error");
            }
          },
          child: Container(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CupertinoColors.white),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: const Text(
                "Accept",
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              await DatabaseService.denyEventRequest(
                  widget.event.id!, widget.uuid);
            } catch (error) {
              debugPrint("Error occurred: $error");
            }
          },
          child: Container(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CupertinoColors.white),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: const Text(
                "Deny",
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
