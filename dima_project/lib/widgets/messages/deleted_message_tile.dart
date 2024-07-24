import 'package:dima_project/models/message.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/message_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class DeletedMessageTile extends StatefulWidget {
  final Message message;

  const DeletedMessageTile({
    required this.message,
    super.key,
  });

  @override
  DeletedMessageTileState createState() => DeletedMessageTileState();
}

class DeletedMessageTileState extends State<DeletedMessageTile> {
  final String uuid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.message.sentByMe!
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!widget.message.sentByMe! && widget.message.isGroupMessage)
                Padding(
                  padding: const EdgeInsets.only(right: 3.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CreateImageWidget.getUserImage(
                          widget.message.senderImage!,
                          small: true,
                        ),
                      ]),
                ),
              Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                      minWidth: 80,
                    ),
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 8.0, left: 8.0, bottom: 24.0),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.trash,
                          color: widget.message.sentByMe!
                              ? CupertinoColors.white.withOpacity(0.5)
                              : CupertinoColors.black.withOpacity(0.3),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Event deleted',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: widget.message.sentByMe!
                                ? CupertinoColors.white.withOpacity(0.5)
                                : CupertinoColors.black.withOpacity(0.3),
                            fontSize: 16,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 12,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
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
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: MessageUtils.buildReadByIcon(widget.message),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
