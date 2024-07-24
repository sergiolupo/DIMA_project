import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventTile extends ConsumerStatefulWidget {
  final Event event;
  const EventTile({
    super.key,
    required this.event,
  });

  @override
  EventTileState createState() => EventTileState();
}

class EventTileState extends ConsumerState<EventTile> {
  final String uid = AuthService.uid;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref.invalidate(eventProvider(widget.event.id!));
              ref.invalidate(joinedEventsProvider(uid));
              ref.invalidate(createdEventsProvider(uid));
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => EventPage(
                    eventId: widget.event.id!,
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
      ],
    );
  }
}
