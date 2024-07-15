import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class EventTile extends StatefulWidget {
  final String uuid;
  final Event event;
  final int isJoined; // 0 is not joined, 1 is joined, 2 is requested
  const EventTile({
    super.key,
    required this.uuid,
    required this.event,
    required this.isJoined,
  });

  @override
  EventTileState createState() => EventTileState();
}

class EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => DetailPage(
                    eventId: widget.event.id!,
                    uuid: widget.uuid,
                  ),
                ),
              );
            },
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
        ),
        GestureDetector(
          onTap: () async {
            try {
              await DatabaseService.toggleEventJoin(
                widget.event.id!,
                FirebaseAuth.instance.currentUser!.uid,
              );
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
              child: Text(
                widget.isJoined == 1
                    ? "Joined"
                    : widget.isJoined == 2
                        ? "Requested"
                        : "Join",
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
