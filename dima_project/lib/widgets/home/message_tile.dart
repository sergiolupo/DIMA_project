import 'package:dima_project/models/message.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';

class MessageTile extends StatefulWidget {
  final Message message;
  final String username;
  const MessageTile({
    super.key,
    required this.message,
    required this.username,
  });

  @override
  MessageTileState createState() => MessageTileState();
}

class MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            : const EdgeInsets.only(
                right: 30,
              ),
        padding: const EdgeInsets.only(
          top: 17,
          bottom: 17,
          left: 20,
          right: 20,
        ),
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
              ClipOval(
                child: Container(
                  width: 20,
                  height: 20,
                  color: CupertinoColors.lightBackgroundGray,
                  child: widget.message.senderImage != ""
                      ? Image.network(
                          widget.message.senderImage,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/default_user_image.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message.sender,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.message.sentByMe!
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.message.content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.message.sentByMe!
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    fontSize: 16,
                  )),
              Text(
                DateUtil.getFormattedDate(
                    context: context,
                    time:
                        widget.message.time.microsecondsSinceEpoch.toString()),
                style: TextStyle(
                  color: widget.message.sentByMe!
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              readBy(),
            ]),
      ),
    );
  }

  Widget readBy() {
    bool hasRead = widget.message.readBy!
        .any((element) => element.username == widget.username);
    if (!hasRead) {
      DatabaseService.updateMessageReadStatus(widget.username, widget.message);
    }

    return widget.message.sentByMe == true
        ? widget.message.readBy!.isNotEmpty &&
                !widget.message.readBy!
                    .every((element) => element.username == widget.username)
            ? const Icon(CupertinoIcons.check_mark_circled,
                color: CupertinoColors.systemBlue, size: 16)
            : const Icon(CupertinoIcons.check_mark_circled,
                color: CupertinoColors.systemGreen, size: 16)
        : const SizedBox();
  }
}
