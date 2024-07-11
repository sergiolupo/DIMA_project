import 'package:dima_project/models/message.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/message_utils.dart';
import 'package:flutter/cupertino.dart';

class ImageMessageTile extends StatefulWidget {
  final Message message;
  final String? senderUsername;
  final String uuid;
  const ImageMessageTile({
    required this.message,
    this.senderUsername,
    required this.uuid,
    super.key,
  });

  @override
  ImageMessageTileState createState() => ImageMessageTileState();
}

class ImageMessageTileState extends State<ImageMessageTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              left: widget.message.sentByMe! ? 0 : 24,
              right: widget.message.sentByMe! ? 24 : 0,
            ),
            alignment: widget.message.sentByMe!
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: widget.message.sentByMe!
                  ? const EdgeInsets.only(left: 30)
                  : const EdgeInsets.only(right: 30),
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
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
                        CreateImageWidget.getUserImage(
                          widget.message.senderImage!,
                          small: true,
                        ),
                        const SizedBox(width: 8),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CreateImageWidget.getImage(
                        widget.message.content,
                        small: false,
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                DateUtil.getFormattedTime(
                                    context: context,
                                    time: widget
                                        .message.time.microsecondsSinceEpoch
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
                                  widget.message, widget.uuid),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
