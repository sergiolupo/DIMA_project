import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:dima_project/widgets/messages/event_deleted_message_tile.dart';
import 'package:dima_project/utils/message_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class EventMessageTile extends ConsumerStatefulWidget {
  final Message message;
  final String? senderUsername;

  const EventMessageTile({
    required this.message,
    this.senderUsername,
    super.key,
  });

  @override
  EventMessageTileState createState() => EventMessageTileState();
}

class EventMessageTileState extends ConsumerState<EventMessageTile> {
  @override
  void initState() {
    ref.read(eventProvider(widget.message.content));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventProvider(widget.message.content));
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    return event.when(
        data: (event) {
          return GestureDetector(
            onLongPress: () => MessageUtils.showBottomSheet(
              context,
              widget.message,
              databaseService,
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
                            const SizedBox(height: 100),
                            CreateImageWidget.getUserImage(
                              widget.message.senderImage!,
                              0,
                            ),
                          ]),
                        ),
                      Container(
                        margin: widget.message.sentByMe!
                            ? const EdgeInsets.only(left: 30)
                            : const EdgeInsets.only(right: 30),
                        padding: const EdgeInsets.only(
                            top: 10, left: 15, right: 8, bottom: 10),
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
                            if (!widget.message.sentByMe! &&
                                widget.message.isGroupMessage)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      widget.senderUsername!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: widget.message.sentByMe!
                                            ? CupertinoColors.white
                                            : CupertinoColors.black,
                                        letterSpacing: -0.5,
                                      ),
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
                                          imagePicker: ImagePicker(),
                                          eventService: EventService(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.4,
                                            child:
                                                CreateImageWidget.getEventImage(
                                              event.imagePath!,
                                              small: true,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: Text(
                                                  event.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: widget
                                                            .message.sentByMe!
                                                        ? CupertinoColors.white
                                                        : CupertinoColors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 150,
                                                child: Text(
                                                  event.description,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: widget
                                                            .message.sentByMe!
                                                        ? CupertinoColors.white
                                                        : CupertinoColors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 30),
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
                  bottom: widget.message.sentByMe! ? 7 : 20,
                  right: widget.message.sentByMe! ? 2 : null,
                  left: widget.message.sentByMe!
                      ? 20
                      : MediaQuery.of(context).size.width > Constants.limitWidth
                          ? 190
                          : MediaQuery.of(context).size.width / 2 - 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        databaseService,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Shimmer.fromColors(
            baseColor: CupertinoTheme.of(context).primaryContrastingColor,
            highlightColor: CupertinoTheme.of(context).primaryContrastingColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: widget.message.sentByMe!
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: widget.message.sentByMe!
                      ? const EdgeInsets.only(left: 30)
                      : const EdgeInsets.only(right: 30),
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryContrastingColor,
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
                  ),
                ),
              ),
            )),
        error: (error, stack) => EventDeletedMessageTile(
              message: widget.message,
              databaseService: databaseService,
            ));
  }
}
