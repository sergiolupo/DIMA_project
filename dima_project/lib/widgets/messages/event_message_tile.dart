import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/message_utils.dart';
import 'package:flutter/cupertino.dart';

class EventMessageTile extends StatefulWidget {
  final Message message;
  final String? senderUsername;
  final String uuid;
  const EventMessageTile({
    required this.message,
    this.senderUsername,
    required this.uuid,
    super.key,
  });

  @override
  EventMessageTileState createState() => EventMessageTileState();
}

class EventMessageTileState extends State<EventMessageTile> {
  Event? event;

  @override
  void initState() {
    fetchEvent();
    super.initState();
  }

  void fetchEvent() async {
    final Event fetchedEvent =
        await DatabaseService.getEvent(widget.message.content);
    if (mounted) {
      setState(() {
        event = fetchedEvent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return event == null
        ? const CupertinoActivityIndicator()
        : GestureDetector(
            onLongPress: () => MessageUtils.showBottomSheet(
              context,
              widget.message,
              widget.uuid,
              showCustomSnackbar: null,
            ),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left: widget.message.sentByMe! ? 24 : 0,
                    right: widget.message.sentByMe! ? 0 : 24,
                  ),
                  alignment: widget.message.sentByMe!
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: widget.message.sentByMe!
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!widget.message.sentByMe! &&
                          widget.message.isGroupMessage)
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Column(children: [
                            const SizedBox(height: 160),
                            CreateImageWidget.getUserImage(
                              widget.message.senderImage!,
                              small: true,
                            ),
                          ]),
                        ),
                      Container(
                        margin: widget.message.sentByMe!
                            ? const EdgeInsets.only(left: 30)
                            : const EdgeInsets.only(right: 30),
                        padding: const EdgeInsets.only(
                            top: 2, left: 8, right: 8, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: widget.message.sentByMe!
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                          color: widget.message.sentByMe!
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.systemGrey,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            widget.message.sentByMe!
                                ? const Padding(
                                    padding: EdgeInsets.all(2),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.senderUsername!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: widget.message.sentByMe!
                                              ? CupertinoColors.white
                                              : CupertinoColors.black,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => EventPage(
                                          eventId: widget.message.content,
                                          uuid: widget.uuid,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CreateImageWidget.getEventImage(
                                        event!.imagePath!,
                                        small: false,
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          event!.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: widget.message.sentByMe!
                                                ? CupertinoColors.white
                                                : CupertinoColors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          event!.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: widget.message.sentByMe!
                                                ? CupertinoColors.white
                                                : CupertinoColors.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: widget.message.sentByMe! ? 10 : 30,
                  right: widget.message.sentByMe! ? 10 : null,
                  left: widget.message.sentByMe!
                      ? 0
                      : MediaQuery.of(context).size.width / 2 - 74,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        DateUtil.getFormattedTime(
                            context: context,
                            time: widget.message.time.microsecondsSinceEpoch
                                .toString()),
                        style: TextStyle(
                          color: widget.message.sentByMe!
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MessageUtils.buildReadByIcon(
                        widget.message,
                        widget.uuid,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
