import 'package:dima_project/models/event.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class EventTile extends StatefulWidget {
  final String uuid;
  final Event event;
  const EventTile({
    super.key,
    required this.uuid,
    required this.event,
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
            onTap: () {},
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
          onTap: () {},
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
                "Join",
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
