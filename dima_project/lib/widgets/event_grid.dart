import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/show_event.dart';
import 'package:flutter/cupertino.dart';

class EventGrid extends StatefulWidget {
  final String uuid;
  final Event event;
  const EventGrid({
    super.key,
    required this.uuid,
    required this.event,
  });

  @override
  EventGridState createState() => EventGridState();
}

class EventGridState extends State<EventGrid> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.white),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ShowEvent(
                uuid: widget.uuid,
                event: widget.event,
              ),
            ),
          );
        },
        child: Container(
          width: 30,
          height: 30,
          color: CupertinoColors.lightBackgroundGray,
          child: widget.event.imagePath != ''
              ? Image.network(
                  widget.event.imagePath!,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/default_event_image.png',
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
